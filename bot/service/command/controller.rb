require 'topic/sns'
require 'request/events/user'
require 'request/events/recipe'

module Service
  module Command 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.data['command'].first
        when '/favourites' 
          bot_request.current = ::Request::Events::Recipes.favourites_requested(source: :command)
          Topic::Sns.broadcast(
            topic: :recipes,
            request: bot_request 
          )
        when '/account'
          bot_request.current = ::Request::Events::Users.account_show_requested(source: :command)
          Topic::Sns.broadcast(
            topic: :users,
            request: bot_request 
          )
        else
          raise "unexpected command #{bot_request.data['command'].first}"
        end
      end
    end
  end
end
