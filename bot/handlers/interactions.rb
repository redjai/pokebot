require 'topic/events/slack'
require 'service/interaction/controller'

module Interactions
  class Handler
    def self.handle(event:, context:)
      begin
        interaction_event = Topic::Events::Slack.interaction_event(event)
        Service::Interaction::Controller.call(interaction_event)
        "hello"
      rescue StandardError => e
        Honeybadger.notify(e, sync: true) #sync true is important as we have no background worker thread
      end
    end
  end
end

