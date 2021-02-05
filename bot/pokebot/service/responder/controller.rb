require 'pokebot/slack/response'

module Pokebot
  module Service
    module Responder
      module Controller
        extend self
        
        def call(pokebot_event)
          respond_to_slack(pokebot_event)
        end

        def respond_to_slack(pokebot_event)
          require_relative 'slack'
          Pokebot::Service::Responder::Slack.call(pokebot_event)
        end
      end
    end
  end
end
