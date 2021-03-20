require 'topic/events/slack'
require 'service/shortcut/controller'

module Shortcuts 
  class Handler
    def self.handle(event:, context:)
      begin
        bot_request = Topic::Events::Slack.shortcut_event(event)
        Service::Shortcut::Controller.call(bot_request)
        "hello"
      rescue StandardError => e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

