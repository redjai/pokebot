require 'lambda/event'
require 'service/message/controller'
require 'net/http'


def handle(event:, context:)
  bot_event = Lambda::Event.slack_api_event(event)

  if bot_event.current['challenge']
    return Lambda::HttpResponse.plain_text_response(bot_event.current['challenge'])
  end

  unless Slack::Authentication.authenticated?(
    timestamp: event['headers']['x-slack-request-timestamp'],
    signature: event['headers']['x-slack-signature'],
         body: event['body'])
    return Lambda::HttpResponse.plain_text('Not authorized', 401)
  end

  Service::Message::Controller.call(bot_event)
end
