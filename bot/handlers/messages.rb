require 'bot/event_builders'
require 'service/message/controller'
require 'net/http'

module Messages
  class Handler
    def self.handle(event:, context:)
      puts event
      bot_request = Bot::EventBuilders.slack_api_event(event)
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
    end
  end
end
