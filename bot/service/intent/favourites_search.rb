require 'topic/sns'
require 'request/events/users'

module Service
  module Intent
    module FavouritesSearch
      extend self
      
      def call(bot_request)
        bot_request.current = ::Request::Events::Recipes.favourites_requested(source: :intent)
        Topic::Sns.broadcast(
          topic: :recipes,
          request: bot_request 
        )
      end 

    end
  end
end
