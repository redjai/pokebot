require 'lambda/event'

EVENTS = [ Bot::Event::FAVOURITES_SEARCH_REQUESTED, 
           Bot::Event::RECIPE_SEARCH_REQUESTED,
           Bot::Event::USER_FAVOURITES_UPDATED ] 

def handle(event:, context:)
  puts event

  Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
    require 'service/recipes/controller'
    Service::Recipe::Controller.call(bot_event)
  end 
end
