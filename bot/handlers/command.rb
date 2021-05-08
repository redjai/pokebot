require 'topic/topic'
require 'service/command/controller'
require 'topic/topic'

module Command 
  class Handler
    def self.handle(event:, context:)
      begin
        bot_request = Topic::Slack.command_request(event)
        Service::Command::Controller.call(bot_request)
        { statusCode: 204 }
      rescue StandardError => e
        raise e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

