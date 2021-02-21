module Service
  module Recipe
    module Controller
      def self.call(bot_event)
        case bot_event.name
        when Bot::Event::RECIPE_SEARCH_REQUESTED 
          require_relative 'spoonacular/free_text_search'
          Service::Recipe::Spoonacular::FreeTextSearch.call(bot_event)
        when Bot::Event::FAVOURITES_SEARCH_REQUESTED 
          require_relative 'spoonacular/favourites_search'
          Service::Recipe::Spoonacular::FavouritesSearch.call(bot_event)
        when Bot::Event::USER_FAVOURITES_UPDATED
          require_relative 'favourites'
          Service::Recipe::Favourite.call(bot_event)
        else
          raise "unexpected event name #{bot_event.name}"
        end
      end
    end
  end
end
