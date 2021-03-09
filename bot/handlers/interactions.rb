require 'topic/events/slack'
require 'service/interaction/controller'

module Interactions
  class Handler
    def self.handle(event:, context:)
      interaction_event = Topic::Events::Slack.interaction_event(event)
      Service::Interaction::Controller.call(interaction_event)
      "hello"
    end
  end
end

