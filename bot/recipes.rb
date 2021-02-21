require 'pokebot/lambda/event'

EVENTS = [ Pokebot::Lambda::Event::FAVOURITES_SEARCH_REQUESTED, 
           Pokebot::Lambda::Event::RECIPE_SEARCH_REQUESTED,
           Pokebot::Lambda::Event::USER_FAVOURITES_UPDATED ] 

def handle(event:, context:)
  puts event

  Pokebot::Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    require 'pokebot/service/recipes/controller'
    Pokebot::Service::Recipe::Controller.call(pokebot_event)
  end 
end
