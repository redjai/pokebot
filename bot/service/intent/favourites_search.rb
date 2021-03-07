require 'topic/sns'
require 'bot/event_builders'

module Service
  module Intent
    module FavouritesSearch
      extend self
      
      def call(bot_request)
        bot_request.current = Bot::EventBuilders.favourite_search_requested(source: :intent)
        Topic::Sns.broadcast(
          topic: :intent,
          event: bot_request 
        )
      end 

    end
  end
end
