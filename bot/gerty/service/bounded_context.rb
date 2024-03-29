
require 'gerty/lib/logger'
require 'honeybadger'
require 'gerty/service/bounded_context_loader'
require 'gerty/topic/sns'

module Gerty
  module Service

    class NilSentry

      def pass?(bot_request)
        true
      end

    end

    class BoundedContext

      @@listens = {}
      @@broadcasts = {}
      @@sentry = NilSentry.new

      def self.listens
        @@listens
      end

      def self.broadcasts
        @@broadcasts
      end

      def self.register_sentry(sentry)
        @@sentry = sentry
      end

      def self.register(service)
        register_listens(service)
        register_broadcasts(service)
      end

      def self.call(bot_request)
        Gerty::LOGGER.debug("request in:")
        Gerty::LOGGER.debug(bot_request.to_json)

        if @@sentry.pass?(bot_request) == false
          Gerty::LOGGER.debug("sentry #{@@sentry} rejected request")
          return
        end

        Gerty::LOGGER.debug("listening: #{listens.inspect}")
        listens.each do |klazz, event_names|
          if event_names.include?(bot_request.name.to_sym)
            call_service(klazz, bot_request)
          end
        end
      end

      private 

      def self.call_service(klazz, bot_request)
        Gerty::LOGGER.debug("calling: #{klazz}")
        begin
          klazz.call(bot_request)
          broadcast_bot_request(klazz, bot_request) if bot_request.events.dirty?
          bot_request.events.clean! #if we call another service we reset the dirty marker
        rescue StandardError => e
          if ENV['HONEYBADGER_API_KEY']
            Honeybadger.notify(e, sync: true, context: error_context(e)) #sync true is important as we have no background worker thread
          else
            raise e
          end
        end
      end

      def self.broadcast_bot_request(klazz, bot_request)
        Gerty::LOGGER.debug("broadcasting on: #{broadcasts.inspect}")
        Gerty::LOGGER.debug("broadcast event:")
        Gerty::LOGGER.debug(bot_request.to_json)
        broadcasts[klazz].each do |topic|
          Gerty::LOGGER.debug("to topic #{topic}:")
          Gerty::Topic::Sns.broadcast(
            topic: topic,
            request: bot_request
          )
        end
      end

      # listens sns: :messages, sqs: :intent, :favourites_updated, :account_updated, :account_read
      def self.register_listens(service)
        listens[service] = service.listen.collect{|name| name.to_sym }
      end

      def self.register_broadcasts(service)
        broadcasts[service] = service.broadcast.collect{|name| name.to_sym }
      end

      def self.error_context(e)
        return nil unless e.respond_to?(:context)
        if e.context.is_a?(Hash)
          e.context
        elsif e.context.respond_to?(:params)
          e.context.params 
        end
      end
    end
  end
end