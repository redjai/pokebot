require 'handlers/processors/sqs'

module Intent
  class Handler
    def self.handle(event:, context:)
      Processors::Sqs.process_sqs(aws_event: event, service: :intent, accept: { messages: %w{ received }})
    end
  end
end
