
require 'handlers/lambda/event'
require 'request/events/topic'

module Kanbanize  
  class Handler
    def self.handle(event:, context:)
      puts event
      Lambda::Event.process_sqs(aws_event: event, controller: :kanbanize, accept: {
        # topic: %w{ event1 event2 },
      })
    end
  end
end
