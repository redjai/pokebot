require 'pokebot/lambda/event'

EVENTS = [ Pokebot::Lambda::Event::RECIPE_IDS_SEARCH_REQUESTED, 
           Pokebot::Lambda::Event::RECIPE_SEARCH_REQUESTED,
           Pokebot::Lambda::Event::FAVOURITE_CREATED ] 

def handle(event:, context:)
  puts event

  Pokebot::Lambda::Event.each_sqs_record_pokebot_event(aws_event: event, accept: EVENTS) do |pokebot_event|
    require 'pokebot/service/recipes/controller'
    Pokebot::Service::Recipe::Controller.call(pokebot_event)
  end 
end
