require 'handlers/processors/sqs'


module Recipes
  class Handler
    def self.handle(event:, context:)
      Processors::Sqs.process_sqs(aws_event: event, controller: :recipe, accept: {
        recipes: %w{ favourites_search_requested search_requested },
         users: %w{ favourites_updated }
      })
    end
  end
end
