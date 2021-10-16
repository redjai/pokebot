require 'gerty/request/event'
require 'gerty/request/events/util'
require 'honeybadger'
require_relative 'logger'
require_relative 'base'

module Processors 
  module Util 
    extend self
   
    def process(aws_event:, service:, controller: nil)
      Gerty::LOGGER.debug(aws_event)      
      handler = UtilHandler.new(service, controller) 
      handler.handle(aws_event)
    end

    class UtilHandler
      include Processors::Base

      def initialize(service, controller)
        @service = service
        @controller_name = controller
      end

      def accept?(bot_request)
        true
      end

      def handle(aws_event)
        begin
          handle_request Gerty::Request::Events::Util.util_request(aws_event)
        rescue StandardError => e
          if ENV['HONEYBADGER_API_KEY']
            Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
          else
            raise e
          end
        end
      end

    end
  end
end
