require 'topic/sns'
require 'request/events/user' 

module Service
  module Intent
    module RecipeSearch
      extend self
      
      def call(bot_request)
        bot_request.current = ::Request::Events::Recipes.search_requested(source: :intent, query: bot_request.data['text'])
        Topic::Sns.broadcast(
           topic: :recipes,
           request: bot_request 
        )
      end 

    end
  end
end
