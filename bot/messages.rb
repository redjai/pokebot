require 'pokebot/lambda/event'
require 'pokebot/service/message/controller'
require 'net/http'


def handle(event:, context:)
  bot_event = Pokebot::Lambda::Event.slack_api_event(event)

  if bot_event.current['challenge']
    return Pokebot::Lambda::HttpResponse.plain_text_response(bot_event.current['challenge'])
  end

  unless Pokebot::Slack::Authentication.authenticated?(
    timestamp: event['headers']['x-slack-request-timestamp'],
    signature: event['headers']['x-slack-signature'],
         body: event['body'])
    return Pokebot::Lambda::HttpResponse.plain_text('Not authorized', 401)
  end

  Pokebot::Service::Message::Controller.call(bot_event)
end
