require 'topic/events/slack'
require 'service/message/controller'
require 'net/http'
require 'topic/topic'

module Messages
  class Handler
    def self.handle(event:, context:)
      begin
        puts event
        bot_request = Topic::Events::Slack.api_event(event)
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
        Honeybadger.notify(e, sync: true, context: (e.respond_to?(:context) ? e.context : nil)) #sync true is important as we have no background worker thread
      end
    end
  end
end
