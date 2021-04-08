require 'handlers/lambda/event'
require 'topic/topic'

module Notifier 
  class Handler
    EVENTS = []

    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :notifications,  accept: EVENTS) do |bot_request|
    end
  end
end

