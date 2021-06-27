require 'request/event'
require 'request/events/cron'
require 'honeybadger'
require_relative 'logger'
require_relative 'base'

module Processors 
  module Cron 
    extend self
   
    def process(aws_event:, controller:)
      Bot::LOGGER.debug(aws_event)      
      handler = CronHandler.new(controller) 
      handler.handle(aws_event)
    end

    class CronHandler
      include Processors::Base

      def initialize(controller)
        @controller_name = controller
      end

      def accept?(bot_request)
        true
      end

      def handle(aws_event)
        begin
          handle_request Request::Events::Cron.cron_request(aws_event)
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
