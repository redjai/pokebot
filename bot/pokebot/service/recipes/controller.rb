module Pokebot
  module Service
    module Recipe
      module Controller
        def self.call(bot_event)
          case bot_event.name
          when Pokebot::Lambda::Event::RECIPE_SEARCH_REQUESTED 
            require_relative 'spoonacular/free_text_search'
            Pokebot::Service::Recipe::Spoonacular::FreeTextSearch.call(bot_event)
          when Pokebot::Lambda::Event::FAVOURITES_SEARCH_REQUESTED 
            require_relative 'spoonacular/favourites_search'
            Pokebot::Service::Recipe::Spoonacular::FavouritesSearch.call(bot_event)
          when Pokebot::Lambda::Event::USER_FAVOURITES_UPDATED
            require_relative 'favourites'
            Pokebot::Service::Recipe::Favourite.call(bot_event)
          else
            raise "unexpected event name #{bot_event.name}"
          end
        end
      end
    end
  end
end  
