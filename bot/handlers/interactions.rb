require 'bot/event_builders'
require 'service/interaction/controller'

module Interactions
  class Handler
    def self.handle(event:, context:)
      interaction_event = Bot::EventBuilders.slack_interaction_event(event)
      Service::Interaction::Controller.call(interaction_event)
      "hello"
    end
  end
end

