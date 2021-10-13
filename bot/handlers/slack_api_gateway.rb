require 'request/events/slack'
require 'service/bounded_context'
require 'service/bounded_context_loader'
require 'handlers/processors/logger'
require 'honeybadger'
require 'slack/authentication'
require 'handlers/processors/http_response'

module SlackApiGateway
  class Handler

    @@loader = nil

    def self.load_bounded_context!
      return unless @@loader.nil?  
      @@loader = Service::BoundedContextLoader.new(name: 'message')
      @@loader.load!
    end

    def self.handle(event:, context:)
      begin
        Bot::LOGGER.debug(event)
        bot_request = ::Request::Events::Slack.api_request(event)
        
        if bot_request.data['challenge']
          return Lambda::HttpResponse.plain_text_response(bot_request.data['challenge'])
        end

        unless Slack::Authentication.authenticated?(
          timestamp: event['headers']['x-slack-request-timestamp'],
          signature: event['headers']['x-slack-signature'],
               body: event['body'])
          return Lambda::HttpResponse.plain_text_response('Not authorized', 401)
        end

        load_bounded_context!

        Service::BoundedContext.call(bot_request)
    
      rescue StandardError => e
        if ENV['HONEYBADGER_API_KEY']
          Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
        else
          raise e
        end
      end
    end
    
    def self.context(e)
      return nil unless e.respond_to?(:context)
      if e.context.is_a?(Hash)
        e.context
      elsif e.context.respond_to?(:params)
        e.context.params 
      end
    end

  end
end


