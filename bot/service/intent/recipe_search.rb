require 'topic/sns'
require 'request/events/messages'
require 'request/events/recipes' 

module Service
  module Intent
    module RecipeSearch
      extend self

      def listen
        [ ::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :recipes ]
      end

      Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /recipe for (.+)$/
          recipe = $1
          bot_request.events << ::Request::Events::Recipes.search_requested(source: :intent, query: recipe)
        end
      end 

    end
  end
end
