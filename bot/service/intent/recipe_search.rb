require 'bot/topic/sns'
require 'bot/event_builders' 

module Service
  module Intent
    module RecipeSearch
      extend self
      
      def call(bot_request)
        bot_request.current = Bot::EventBuilders.recipe_search_requested(source: :recipes, query: bot_request.data['text'])
        Topic::Sns.broadcast(
           topic: :intent,
           event: bot_request 
        )
      end 

    end
  end
end
