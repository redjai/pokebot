require 'handlers/processors/sqs'
require 'gerty/request/events/kanbanize'

module Kanbanize
  module Imports 
    class Handler
      def self.handle(event:, context:)
        Processors::Sqs.process_sqs(
          aws_event: event, 
          service: :kanbanize, 
          accept: { kanbanize: %w{ activities_imported new_activities_found tasks_found archived_tasks_found tasks_imported } }
        )
      end
    end
  end
end
