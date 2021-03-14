require 'slack/response'

module Service
  module Responder
    module Controller
      extend self
      
      def call(bot_request)
        respond_to_slack(bot_request)
      end

      def respond_to_slack(bot_request)
        require_relative 'slack/spoonacular/recipes'
        Service::Responder::Slack::Spoonacular::Recipes.call(bot_request)
      end
    end
  end
end
