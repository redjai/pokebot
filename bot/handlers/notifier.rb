require 'handlers/lambda/event'

module Notifier 
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :notifications,  accept: {}) do |bot_request|
    end
  end
end

