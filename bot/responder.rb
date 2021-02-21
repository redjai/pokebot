require 'lambda/event'

EVENTS = [Bot::Event::RECIPES_FOUND, Bot::Event::MESSAGE_RECEIVED]

def handle(event:, context:)
  Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
    require 'service/responder/controller'
    Service::Responder::Controller.call(bot_event)
  end 
end


