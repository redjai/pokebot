require 'pokebot/topic/sns'

module Pokebot
  module Service
    module Intent
      module FavouritesSearch
        extend self
        
        def call(event)
          Pokebot::Topic::Sns.broadcast(
            topic: :intent, 
            source: :intent,
            name: Bot::Event::FAVOURITES_SEARCH_REQUESTED, 
            version: 1.0,
            event: event,
            data: { user: event.data['user'] }
          )
        end 

      end
    end
  end
end 
