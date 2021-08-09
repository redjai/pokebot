require 'storage/kanbanize/s3/task'

module Storage
  module Postgres
    class ColumnDurations
      def initialize(client_id:, board_id:, task_id:, workflow:, history_details:)
        @client_id = client_id
        @board_id = board_id
        @task_id = task_id
        @workflow = workflow
        @history_details = history_details
      end

      def valid?
        created && movements.first
      end

      def movements
        @movements ||= @history_details.select { |history_detail| history_detail.moved? }.sort_by(&:id)
      end

      def created
        @history_details.find{ |detail| detail.created? }
      end

      def archived
        @history_details.find{ |detail| detail.archived? }
      end

      def resource
        @resource ||= Aws::RDSDataService::Resource.new(region: ENV['REGION'])
      end

      def store!
        execute(delete_history(@task_id))
        execute(history_movement_sql(created, movements.first))
        movements.each_cons(2) do |movements|
          execute(history_movement_sql(movements.first, movements.last)) 
        end
        execute(history_movement_sql(movements.last, archived))
      end

      def execute(sql)
        resource.client.execute_statement({
          database: ENV['KANBANIZE_DB_NAME'],
          resource_arn: ENV['KANBANIZE_DB_CLUSTER'],
          secret_arn: ENV['KANBANIZE_DB_SECRET_ARN'],
          sql: sql
        })
      end

      def task
        "#{@client_id}:#{@board_id}:#{@task_id}"
      end

      def delete_history(history_detail)
        %Q{
          DELETE FROM
            public.column_durations
          WHERE
            task = '#{task}'
        }
      end

      def history_created_sql(history_detail, first_movement_history_detail)
        %Q{
           INSERT INTO 
             public.column_durations(
              task,
              workflow,
              board_id,
              column_name,
              entry_history_id,
              entry_details,
              entry_event_type,
              entry_history_event,
              entry_at,
              exit_history_id, 
              exit_at, 
              exit_details,
              exit_event_type,
              exit_history_event
           ) VALUES (
              '#{task}',
              '#{@workflow}',
              '#{@board_id}',
              '#{first_movement_history_detail[:from]}',
              '#{history_detail.id}',
              '#{history_detail.details_sql_safe}',
              '#{history_detail.event_type}',
              '#{history_detail.history_event}',
              '#{history_detail.timestamp}',
              '#{first_movement_history_detail.id}', 
              '#{first_movement_history_detail.timestamp}', 
              '#{first_movement_history_detail.details_sql_safe}',
              '#{first_movement_history_detail.event_type}',
              '#{first_movement_history_detail.history_event}'
           ) ON CONFLICT DO NOTHING
        }
      end

      def column_name(from, to)
        if from.created?
          to[:from]
        elsif to.archived?
          from[:from]
        else
          from[:to]
        end
      end

      def history_movement_sql(entry_history_detail, exit_history_detail)
        %Q{
           INSERT INTO 
             public.column_durations(
              task,
              workflow,
              board_id,
              column_name,
              entry_history_id,
              entry_details,
              entry_event_type,
              entry_history_event,
              entry_at,
              exit_history_id, 
              exit_details,
              exit_event_type,
              exit_history_event,
              exit_at
           ) VALUES (
              '#{task}',
              '#{@workflow}',
              '#{@board_id}',
              '#{column_name(entry_history_detail, exit_history_detail)}',
              '#{entry_history_detail.id}',
              '#{entry_history_detail.details_sql_safe}',
              '#{entry_history_detail.event_type}',
              '#{entry_history_detail.history_event}',
              '#{entry_history_detail.timestamp}',
              '#{exit_history_detail.id}',
              '#{exit_history_detail.details_sql_safe}',
              '#{exit_history_detail.event_type}',
              '#{exit_history_detail.history_event}',
              '#{exit_history_detail.timestamp}'
           ) ON CONFLICT DO NOTHING
        }
      end

      def history_exit_sql(history_detail)
        %Q{
           UPDATE  
              public.column_durations
           SET 
              exit_history_id = #{history_detail.id}, 
              exit_at = '#{history_detail.timestamp}', 
              exit_details = '#{history_detail.details_sql_safe}',
              exit_event_type = '#{history_detail.event_type}',
              exit_history_event = '#{history_detail.history_event}'
           FROM (
             SELECT entry_history_id FROM public.column_durations
             WHERE task = '#{task}'
             AND column_name = '#{history_detail[:from]}'
             AND exit_history_id IS NULL 
             AND entry_history_id < #{history_detail.id}
             ORDER BY entry_history_id ASC
             LIMIT 1
           ) AS subquery WHERE public.column_durations.entry_history_id = subquery.entry_history_id returning subquery.entry_history_id ;
        }
      end

      def history_archived_sql(history_detail)
        %Q{
           UPDATE  
              public.column_durations
           SET 
              exit_history_id = #{history_detail.id}, 
              exit_at = '#{history_detail.timestamp}', 
              exit_details = '#{history_detail.details_sql_safe}',
              exit_event_type = '#{history_detail.event_type}',
              exit_history_event = '#{history_detail.history_event}'
           FROM (
             SELECT entry_history_id FROM public.column_durations
             WHERE task = '#{task}'
             AND exit_history_id IS NULL 
             AND entry_history_id < #{history_detail.id}
             LIMIT 1
           ) AS subquery WHERE public.column_durations.entry_history_id = subquery.entry_history_id returning subquery.entry_history_id ;
        }
      end
    end
  end
end