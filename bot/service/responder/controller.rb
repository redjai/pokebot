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
          require_relative 'actions/recipes/index'
          Service::Responder::Actions::Recipes::Index.call(bot_request)
        when Topic::Messages::RECEIVED
          require_relative 'actions/searching/index'
          Service::Responder::Actions::Searching::Index.call(bot_request)
        when Topic::Users::FAVOURITES_UPDATED
          require_relative 'actions/favourites/updated'
          Service::Responder::Actions::Favourites::Updated.call(bot_request)
        when Topic::Users::ACCOUNT_READ
          require_relative 'actions/account/read'
          Service::Responder::Actions::Account::Read.call(bot_request)
        when Topic::Users::ACCOUNT_UPDATED
          require_relative 'actions/account/updated'
          Service::Responder::Actions::Account::Updated.call(bot_request)
        else
          raise "unexpected request #{bot_request.name}"
        end
      end
    end
  end
end
