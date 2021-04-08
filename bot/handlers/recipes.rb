require 'handlers/lambda/event'
require 'topic/topic'

module Recipes
  class Handler
    EVENTS = [ Topic::Recipes::FAVOURITES_SEARCH_REQUESTED, 
               Topic::Recipes::SEARCH_REQUESTED,
               Topic::Users::FAVOURITES_UPDATED ] 
    
    def self.handle(event:, context:)
      puts event
      Lambda::Event.process_sqs(aws_event: event, controller: :recipe, accept: EVENTS)
    end
  end
end
