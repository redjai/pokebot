
module Service
  module Intent
    module Controller
      extend self

      def call(bot_request)

        case bot_request.current['data']['text']
        when /like/
          # do nothing now
        when /dislike/
         # do nothing for now
        when /favourite/
          require_relative 'favourites_search'
          Service::Intent::FavouritesSearch.call(bot_request)
        else
          require_relative 'recipe_search'
          Service::Intent::RecipeSearch.call(bot_request)
        end  
      end
    end
  end
end
