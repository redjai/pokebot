require 'handlers/lambda/event'

module Intent
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :intent, accept: { messages: %w{ received }})
    end
  end
end
