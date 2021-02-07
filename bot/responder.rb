require 'pokebot/lambda/event'

EVENTS = [Pokebot::Lambda::Event::RECIPES_FOUND]

def handle(event:, context:)
  puts event
  Pokebot::Lambda::Event.each_sqs_record_pokebot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    puts pokebot_event
    require 'pokebot/service/responder/controller'
    Pokebot::Service::Responder::Controller.call(pokebot_event)
  end 
end


