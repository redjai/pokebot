require 'pokebot/lambda/event'

EVENTS = [Bot::Event::FAVOURITE_NEW] 

def handle(event:, context:)
  puts event

  Pokebot::Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    require 'pokebot/service/user/controller'
    Pokebot::Service::User::Controller.call(pokebot_event)
  end 
end
