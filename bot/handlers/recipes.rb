require 'handlers/lambda/event'
require 'topic/topic'

module Recipes
  class Handler
    def self.handle(event:, context:)
      puts event
      Lambda::Event.process_sqs(aws_event: event, controller: :recipe, accept: {
        recipes: %w{ favourites_search_requested search_requested, favourites_updated }
      })
    end
  end
end
