require 'topic/sns'
require 'gerty/request/events/messages'
require 'gerty/request/events/recipes' 

module Service
  module Intent
    module RecipeSearch
      extend self

      def listen
        [ Gerty::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :recipes ]
      end

      Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /recipe for (.+)$/
          recipe = $1
          bot_request.events << Gerty::Request::Events::Recipes.search_requested(source: :intent, query: recipe)
        end
      end 

    end
  end
end
