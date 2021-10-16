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
        when Gerty::Request::Events::Recipes::FOUND
          require_relative 'actions/recipes/index'
          Service::Responder::Actions::Recipes::Index.call(bot_request)
        when Gerty::Request::Events::Messages::RECEIVED
          require_relative 'actions/searching/index'
          Service::Responder::Actions::Searching::Index.call(bot_request)
        when Gerty::Request::Events::Users::FAVOURITES_UPDATED
          require_relative 'actions/favourites/updated'
          Service::Responder::Actions::Favourites::Updated.call(bot_request)
        when Gerty::Request::Events::Users::ACCOUNT_READ
          require_relative 'actions/account/read'
          Service::Responder::Actions::Account::Read.call(bot_request)
        when Gerty::Request::Events::Users::ACCOUNT_UPDATED
          require_relative 'actions/account/updated'
          Service::Responder::Actions::Account::Updated.call(bot_request)
        when Gerty::Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND
          require_relative 'actions/firehose/activities'
          require_relative 'actions/firehose/blockages'
          Service::Responder::Actions::Firehose::Activities.call(bot_request)
          Service::Responder::Actions::Firehose::Blockages.call(bot_request)
        else
          raise "unexpected request #{bot_request.name}"
        end
      end
    end
  end
end
