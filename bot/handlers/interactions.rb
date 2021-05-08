require 'topic/topic'
require 'service/interaction/controller'

module Interactions
  class Handler
    def self.handle(event:, context:)
      Bot::LOGGER.debug(event)
      begin
        bot_request = Topic::Slack.interaction_request(event)
        Bot::LOGGER.debug(bot_request.data.inspect) # payload is encrypted
        Service::Interaction::Controller.call(bot_request)
        { statusCode: 204 }
      rescue StandardError => e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

