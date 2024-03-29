require 'gerty/request/events/slack'
require 'gerty/service/bounded_context_loader'
require 'gerty/service/bounded_context'
require 'gerty/lib/logger'


module Interactions
  class Handler

    @@loader = nil

    def self.load_bounded_context!
      return unless @@loader.nil?  
      @@loader = Gerty::Service::BoundedContextLoader.new(name: 'interaction')
      @@loader.load!
    end

    def self.handle(event:, context:)
      Gerty::LOGGER.debug(event)
      begin
        bot_request = Gerty::Request::Events::Slack.interaction_request(event)
        Gerty::LOGGER.debug(bot_request.data.inspect) # payload is encrypted

        load_bounded_context!

        Gerty::Service::BoundedContext.call(bot_request)
        
        { statusCode: 204 }
      rescue StandardError => e
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end

