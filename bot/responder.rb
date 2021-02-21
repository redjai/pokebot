require 'pokebot/lambda/event'

EVENTS = [Pokebot::Lambda::Event::RECIPES_FOUND, Pokebot::Lambda::Event::MESSAGE_RECEIVED]

def handle(event:, context:)
  Pokebot::Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
    require 'pokebot/service/responder/controller'
    Pokebot::Service::Responder::Controller.call(bot_event)
  end 
end


