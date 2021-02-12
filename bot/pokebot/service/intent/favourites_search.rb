require 'pokebot/topic/sns'

module Pokebot
  module Service
    module Intent
      module RecipeIdsSearch
        extend self
        
        def call(event)
          Pokebot::Topic::Sns.broadcast(
            topic: :intent, 
            event: Pokebot::Lambda::Event::FAVOURITES_SEARCH_REQUESTED, 
            state: event.state
          )
        end 

      end
    end
  end
end 
