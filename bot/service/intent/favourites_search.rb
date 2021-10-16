require 'topic/sns'
require 'request/events/messages'
require 'request/events/recipes' 

module Service
  module Intent
    module FavouritesSearch
      extend self

      def listen
        [ ::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :recipes ]
      end

      Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /my favourite/
          bot_request.events << ::Request::Events::Recipes.favourites_requested(source: :intent)
        end
      end 

    end
  end
end
