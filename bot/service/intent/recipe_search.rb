require 'topic/sns'
require 'topic/topic' 

module Service
  module Intent
    module RecipeSearch
      extend self
      
      def call(bot_request)
        bot_request.intent = Topic::Recipes.search_requested(source: :intent, query: bot_request.data['text'])
        Topic::Sns.broadcast(
           topic: :recipes,
           event: bot_request 
        )
      end 

    end
  end
end
