require 'slack/response'

module Service
  module Responder
    module Controller
      extend self
      
      def call(bot_request)
        respond_to_slack(bot_request)
      end

      def respond_to_slack(bot_request)
        case bot_request.name
        when Topic::Recipes::FOUND
          require_relative 'slack/spoonacular/recipes'
          Service::Responder::Slack::Spoonacular::Recipes.call(bot_request)
        when Topic::Messages::RECEIVED
          require_relative 'slack/spoonacular/searching'
          Service::Responder::Slack::Spoonacular::Searching.call(bot_request)
        when Topic::Users::FAVOURITES_UPDATED
          require_relative 'slack/spoonacular/favourites'
          Service::Responder::Slack::Spoonacular::Favourites.call(bot_request)
        when Topic::Users::ACCOUNT_UPDATE
          require_relative 'slack/account'
          Service::Responder::Slack::Account.call(bot_request)
        end
      end
    end
  end
end
