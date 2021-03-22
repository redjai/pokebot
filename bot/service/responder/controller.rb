require 'slack/response'

module Service
  module Responder
    module Controller
      extend self
      
      def call(bot_request)
        respond_to_slack(bot_request)
      end

      def respond_to_slack(bot_request)
        require_relative 'slack/spoonacular/recipes/recipes'
        Service::Responder::Slack::Recipes::Spoonacular::Respond.call(bot_request)
      end
    end
  end
end
