require 'handlers/lambda/event'
require 'request/events/topic'

module Notifier 
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :notifications,  accept: {}) do |bot_request|
    end
  end
end

