require 'lambda/event'

module Intent
  class Handler
    EVENTS = [Bot::MESSAGE_RECEIVED] 
    def self.handle(event:, context:)
      puts "------"
      Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
        require 'service/intent/controller'
        Service::Intent::Controller.call(bot_event)
      end 
    end
  end
end
