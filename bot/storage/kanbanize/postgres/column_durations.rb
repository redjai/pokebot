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

      def movements
        @movements ||= @history_details.select do |history_detail| 
          history_detail.moved_column? || history_detail.created? || history_detail.archived?
        end.sort_by(&:id)
      end

      def resource
        @resource ||= Aws::RDSDataService::Resource.new(region: ENV['REGION'])
      end

      def store!
        execute(delete_history(@task_id))
        movements.each do |movement|
          execute(history_created_sql(movement)) if movement.created?
          execute(history_entry_sql(movement))  if movement.moved_column?
          execute(history_exit_sql(movement)) if movement.moved_column?
          execute(history_archived_sql(movement))  if movement.archived?
        end
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

      def history_created_sql(history_detail)
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
              entry_at
           ) VALUES (
              '#{task}',
              '#{@workflow}',
              '#{@board_id}',
              'UNKNOWN - CREATED',
              '#{history_detail.id}',
              '#{history_detail.details_sql_safe}',
              '#{history_detail.event_type}',
              '#{history_detail.history_event}',
              '#{history_detail.timestamp}'
           ) ON CONFLICT DO NOTHING
        }
      end

      def history_entry_sql(history_detail)
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
              entry_at
           ) VALUES (
              '#{task}',
              '#{@workflow}',
              '#{@board_id}',
              '#{history_detail[:to]}',
              '#{history_detail.id}',
              '#{history_detail.details_sql_safe}',
              '#{history_detail.event_type}',
              '#{history_detail.history_event}',
              '#{history_detail.timestamp}'
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