require 'handlers/lambda/event'
require 'topic/topic'

module Intent
  class Handler
    EVENTS = [Topic::Messages::RECEIVED] 
    def self.handle(event:, context:)
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/intent/controller'
        Service::Intent::Controller.call(bot_request)
      end 
    end
  end
end
