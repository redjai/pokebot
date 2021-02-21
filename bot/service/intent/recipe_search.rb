require 'topic/sns'

module Service
  module Intent
    module RecipeSearch
      extend self
      
      def call(event)
        Topic::Sns.broadcast(
           topic: :intent, 
          source: :recipes,
            name: Bot::Event::RECIPE_SEARCH_REQUESTED, 
         version: 1.0,
           event: event,
            data: { 
                  query: event.data['text'],
                  user: event.data['user'] 
                }
        )
      end 

    end
  end
end
