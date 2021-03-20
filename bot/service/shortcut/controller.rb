require 'topic/sns'
require 'topic/events/recipes'

module Service
  module Shortcut 
    module Controller
      extend self

      def call(bot_request)
        bot_request.current = Topic::Events::Recipes.favourites_requested(source: :intent)
        Topic::Sns.broadcast(
          topic: :recipes,
          event: bot_request 
        )
      end
    end
  end
end
