require 'handlers/lambda/event'
require 'topic/topic'

module Intent
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :intent, accept: ['messages#received'])
    end
  end
end
