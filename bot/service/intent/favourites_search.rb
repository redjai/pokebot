require 'topic/sns'

module Service
  module Intent
    module FavouritesSearch
      extend self
      
      def call(bot_event)
        bot_event.current = Bot::EventBuilders.favourite_search_requested(source: :intent)
        Topic::Sns.broadcast(
          topic: :intent,
          event: bot_event 
        )
      end 

    end
  end
end
