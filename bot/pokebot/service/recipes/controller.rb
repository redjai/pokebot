require_relative 'event'

module Pokebot
  module Service
    module Recipe
      module Controller
        def self.call(pokebot_event)
          event = Pokebot::Service::Recipe::Event.new(pokebot_event)
          case event.type
          when Pokebot::Lambda::Event::RECIPE_SEARCH_REQUESTED 
            require_relative 'spoonacular/free_text_search'
            Pokebot::Service::Recipe::Spoonacular::FreeTextSearch.call(event)
          when Pokebot::Lambda::Event::RECIPE_IDS_SEARCH_REQUESTED 
            require_relative 'spoonacular/ids_search'
            Pokebot::Service::Recipe::Spoonacular::FreeTextSearch.call(event)
          when Pokebot::Lambda::Event::FAVOURITE_CREATED
            require_relative 'favourites'
            Pokebot::Service::Recipe::Favourite.call(event)
          end
        end
      end
    end
  end
end  
