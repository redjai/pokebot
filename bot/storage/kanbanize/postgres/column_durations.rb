require 'storage/kanbanize/s3/task'

module Storage
  module Postgres
    class ColumnDurations
      def initialize(client_id:, board_id:, history_details:)
        @client_id = client_id
        @board_id = board_id
        @history_details = history_details
      end

      def movements
        @movements ||= @history_details.select{|history_detail| history_detail.history_event == 'Task moved'  && history_detail.details != "The task was reordered within the same board cell." }
      end

      def resource
        @resource ||= Aws::RDSDataService::Resource.new(region: ENV['REGION'])
      end

      def store!
        movements.each do |movement|
          execute(history_entry_sql(movement))
          #execute(history_exit_sql(movement)) 
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

      def column_name(task_id, column_name)
        "#{@client_id}:#{@board_id}:#{task_id}:#{column_name}"
      end

      def history_entry_sql(history_detail)
        %Q{
           INSERT INTO 
             public.column_durations(
              column_name,
              entry_history_id,
              entry_at
           ) VALUES (
              '#{column_name(history_detail.task_id, history_detail[:to])}',
              '#{history_detail.id}',
              '#{history_detail.timestamp}'
           ) ON CONFLICT DO NOTHING
        }
      end

      def history_exit_sql(history_detail)
        %Q{
           UPDATE  
             public.column_durations
           SET exit_history_id = #{history_detail.id}, exit_at = #{history_detail.timestamp}
           FROM (
             SELECT entry_history_id FROM public.column_durations
             WHERE column_name = '#{column_name(history_detail.task_id, history_detail[:from])}'
             AND exit_history_id IS NULL ORDER BY entry_at ASC
             LIMIT 1
           ) AS subquery WHERE entry_history_id = subquery.entry_history_id returning entry_history_id
        }
      end
    end
  end
end