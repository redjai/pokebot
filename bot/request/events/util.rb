require_relative '../base'
require_relative '../event'

# sls invoke \
# -f kanbanize_util \
# --stage development \
# -d "{\"client_id\":\"livelink\",\"action\":\"find-tasks\",\"archive\":\"2021-07-1:2021-08-1\"}"

module Request
  module Events
    module Util
    extend self
    extend ::Request::Base

      module Actions
        FIND_TASKS = 'find-tasks'
        DB_MIGRATE = 'db-migrate'    
      end

      def util_request(aws_event)
        ::Request::Request.new current: util_event(aws_event)
      end

      def util_event(aws_event)
        ::Request::Event.new(
          name: aws_event['action'],
          source: aws_event['source'],
          version: 1.0,
          data: aws_event
        )  
      end
    end
  end
end
