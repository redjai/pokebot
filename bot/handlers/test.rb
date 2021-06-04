
require 'handlers/processors/sqs'

module Test  
  class Handler
    def self.handle(event:, context:)
      puts event
      Processors::Sqs.process_sqs(aws_event: event, controller: :test, accept: {
        # topic: %w{ event1 event2 },
      })
    end
  end
end
