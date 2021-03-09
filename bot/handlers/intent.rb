require 'handlers/lambda/event'

module Intent
  class Handler
    EVENTS = [Topic::MESSAGE_RECEIVED] 
    def self.handle(event:, context:)
      puts "------"
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/intent/controller'
        Service::Intent::Controller.call(bot_request)
      end 
    end
  end
end
