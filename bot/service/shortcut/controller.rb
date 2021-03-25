require 'topic/sns'
require 'topic/topic'

module Service
  module Shortcut 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.data['command'].first
        when '/favourites' 
          bot_request.current = Topic::Recipes.favourites_requested(source: :intent)
          Topic::Sns.broadcast(
            topic: :recipes,
            event: bot_request 
          )
        else
          raise "unexpected command #{bot_request.data['command'].first}"
        end
      end
    end
  end
end
