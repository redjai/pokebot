require 'topic/topic'
require 'service/message/controller'
require 'net/http'
require 'topic/topic'

module Messages
  class Handler
    def self.handle(event:, context:)
      begin
        Bot::LOGGER.debug(event)
        bot_request = Topic::Slack.api_request(event)
        
        if bot_request.data['challenge']
          return Lambda::HttpResponse.plain_text_response(bot_request.data['challenge'])
        end

        unless Slack::Authentication.authenticated?(
          timestamp: event['headers']['x-slack-request-timestamp'],
          signature: event['headers']['x-slack-signature'],
               body: event['body'])
          return Lambda::HttpResponse.plain_text_response('Not authorized', 401)
        end

        Service::Message::Controller.call(bot_request)
    
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
