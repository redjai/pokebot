require 'topic/sns'
require 'bot/event_builders' 

module Service
  module Intent
    module RecipeSearch
      extend self
      
      def call(bot_event)
        bot_event.current = Bot::EventBuilders.recipe_search_requested(source: :recipes, query: bot_event.data['text'])
        Topic::Sns.broadcast(
           topic: :intent,
           event: bot_event 
        )
      end 

    end
  end
end
