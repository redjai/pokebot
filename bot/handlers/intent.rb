require 'handlers/lambda/event'
require 'topic/topic'

module Intent
  class Handler
    EVENTS = [Topic::Messages::RECEIVED] 
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :intent, accept: EVENTS)
    end
  end
end
