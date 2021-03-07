require 'lambda/event'

module Recipes
  class Handler
    EVENTS = [ Bot::FAVOURITES_SEARCH_REQUESTED, 
               Bot::RECIPE_SEARCH_REQUESTED,
               Bot::USER_FAVOURITES_UPDATED ] 
    
    def self.handle(event:, context:)
      puts event

      Lambda::Event.each_sqs_record_bot_event(aws_event: event, accept: EVENTS) do |bot_event|
        require 'service/recipes/controller'
        Service::Recipe::Controller.call(bot_event)
      end 
    end
  end
end
