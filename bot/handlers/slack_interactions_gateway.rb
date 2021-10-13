require 'request/events/slack'
require 'service/interaction/controller'

module Interactions
  class Handler

    @@loader = nil

    def self.load_bounded_context!
      return unless @@loader.nil?  
      @@loader = Service::BoundedContextLoader.new(name: 'interaction')
      @@loader.load!
    end

    def self.handle(event:, context:)
      Bot::LOGGER.debug(event)
      begin
        bot_request = ::Request::Events::Slack.interaction_request(event)
        Bot::LOGGER.debug(bot_request.data.inspect) # payload is encrypted

        load_bounded_context!

        BoundedContextLoader.call(bot_request)
        
        { statusCode: 204 }
      rescue StandardError => e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

