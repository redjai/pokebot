require_relative '../base'
require_relative '../event'

module Request
  module Events
    module Util
    extend self
    extend ::Request::Base

      module Actions
        FIND_TASKS = 'find-tasks'
        DB_MIGRATE = 'db-migrate'    
      end

      MANUAL_REQUEST = 'manual-request'

      def util_request(aws_event)
        ::Request::Request.new current: util_event(aws_event)
      end

      def util_event(aws_event)
        ::Request::Event.new(
          name: ::Request::Events::Util::MANUAL_REQUEST,
          source: aws_event['source'],
          version: 1.0,
          data: aws_event
        )  
      end
    end
  end
end
