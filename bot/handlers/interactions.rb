require 'topic/topic'
require 'service/interaction/controller'

module Interactions
  class Handler
    def self.handle(event:, context:)
      begin
        bot_request = Topic::Slack.interaction_event(event)
        Service::Interaction::Controller.call(bot_request)
        "hello"
      rescue StandardError => e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

