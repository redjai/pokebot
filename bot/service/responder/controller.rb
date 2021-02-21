require 'slack/response'

module Service
  module Responder
    module Controller
      extend self
      
      def call(bot_event)
        respond_to_slack(bot_event)
      end

      def respond_to_slack(bot_event)
        require_relative 'slack'
        Service::Responder::Slack.call(bot_event)
      end
    end
  end
end
