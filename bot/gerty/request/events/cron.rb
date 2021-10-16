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
      end
    end
  end
end
