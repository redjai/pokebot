require 'pokebot/lambda/event'

EVENTS = [Bot::Event::MESSAGE_RECEIVED] 

def handle(event:, context:)
  Pokebot::Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
    require 'pokebot/service/intent/controller'
    Pokebot::Service::Intent::Controller.call(bot_event)
  end 
end
