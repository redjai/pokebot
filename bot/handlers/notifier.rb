require 'handlers/processors/sqs'

module Notifier 
  class Handler
    def self.handle(event:, context:)
      Processors::Sqs.process_sqs(aws_event: event, service: :notifications,  accept: {}) do |bot_request|
    end
  end
end

