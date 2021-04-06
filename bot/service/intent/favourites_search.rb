require 'topic/sns'
require 'topic/topic'

module Service
  module Intent
    module FavouritesSearch
      extend self
      
      def call(bot_request)
        bot_request.current = Topic::Recipes.favourites_requested(source: :intent)
        Topic::Sns.broadcast(
          topic: :recipes,
          request: bot_request 
        )
      end 

    end
  end
end
