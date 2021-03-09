require 'handlers/lambda/event'

module Recipes
  class Handler
    EVENTS = [ Topic::FAVOURITES_SEARCH_REQUESTED, 
               Topic::RECIPE_SEARCH_REQUESTED,
               Topic::USER_FAVOURITES_UPDATED ] 
    
    def self.handle(event:, context:)
      puts event

      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/recipes/controller'
        Service::Recipe::Controller.call(bot_request)
      end 
    end
  end
end
