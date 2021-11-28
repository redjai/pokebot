require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Cron
      extend self
      extend Gerty::Request::Base

        module Actions
          KANBANIZE_IMPORT_ACTIVITIES = 'kanbanize-import-activities'
          FIND_TASK_IDS_FOR_BOARDS = 'find_task_ids_for_boards'
          FIND_ARCHIVE_TASK_IDS_FOR_BOARDS = 'find_archive_task_ids_for_boards'
          COLUMN_STAY_INSIGHTS_BUILD_REQUESTED = 'column_stay_insights_build_requested'
          POP_COMMAND = 'pop_command'    
        end

        SCHEDULED_REQUEST = 'cron-scheduled-request' 

        def cron_request(aws_event)
          Gerty::Request::Request.new current: cron_event(aws_event)
        end

        def cron_event(aws_event)
          aws_event['date'] ||= Date.today.to_s
          Gerty::Request::Event.new(
            name: aws_event['action'],
            source: 'aws-cron',
            version: 1.0,
            data: aws_event
          )  
        end

        def command_popped(source:, action:, data:)
          Gerty::Request::Event.new(source: source, name: action, version: 1.0, data: data)      
        end
      
      end
    end
  end
end
