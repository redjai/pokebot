require 'handlers/processors/sqs'
require 'request/events/kanbanize'

module Kanbanize
  module Sqs 
    class Handler
      def self.handle(event:, context:)
        Processors::Sqs.process_sqs(
          aws_event: event, 
          service: :kanbanize, 
          accept: { kanbanize: %w{ activities_imported new_activities_found } }
        )
      end
    end
  end
end
