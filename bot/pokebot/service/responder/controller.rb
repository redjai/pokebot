require 'pokebot/slack/response'
require_relative 'event'

module Pokebot
  module Service
    module Responder
      module Controller
        extend self
        
        def call(pokebot_event)
          event = Pokebot::Service::Responder::Event.new(pokebot_event)
          respond_to_slack(event)
        end

        def respond_to_slack(event)
          require_relative 'slack'
          Pokebot::Service::Responder::Slack.call(event)
        end
      end
    end
  end
end
