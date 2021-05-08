
require 'handlers/lambda/event'
require 'topic/topic'

module Test  
  class Handler
    def self.handle(event:, context:)
      puts event
      Lambda::Event.process_sqs(aws_event: event, controller: :test, accept: {
        # topic: %w{ event1 event2 },
      })
    end
  end
end
