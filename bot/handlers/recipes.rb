require 'handlers/lambda/event'
require 'topic/topic'

module Recipes
  class Handler
    EVENTS = [ Topic::Recipes::FAVOURITES_SEARCH_REQUESTED, 
               Topic::Recipes::SEARCH_REQUESTED,
               Topic::Users::FAVOURITES_UPDATED ] 
    
    def self.handle(event:, context:)
      puts event

      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/recipes/controller'
        Service::Recipe::Controller.call(bot_request)
      end 
    end
  end
end
