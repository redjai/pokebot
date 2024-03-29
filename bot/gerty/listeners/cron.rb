require 'gerty/request/events/cron'
require 'gerty/service/bounded_context'
require 'gerty/service/bounded_context_loader'
require 'gerty/lib/logger'

 
module Cron
  class Handler
    
    @@loader = nil

    def self.handle(event:, context:)
      Gerty::LOGGER.debug(event)
      Gerty::LOGGER.debug(context)
      
      load_bounded_context!(event['bounded_context']) unless @@loader

      bot_request = Gerty::Request::Events::Cron.cron_request(event)
      Gerty::Service::BoundedContext.call(bot_request)
    end

    def self.load_bounded_context!(name)
      @@loader = Gerty::Service::BoundedContextLoader.new(name: name)
      @@loader.load!
    end
  end
end
