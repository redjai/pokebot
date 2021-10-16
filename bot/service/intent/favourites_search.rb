require 'topic/sns'
require 'gerty/request/events/messages'
require 'gerty/request/events/recipes' 

module Service
  module Intent
    module FavouritesSearch
      extend self

      def listen
        [ Gerty::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :recipes ]
      end

      Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /my favourite/
          bot_request.events << Gerty::Request::Events::Recipes.favourites_requested(source: :intent)
        end
      end 

    end
  end
end
