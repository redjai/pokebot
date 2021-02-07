require 'pokebot/lambda/event'
require 'pokebot/service/message/controller'
require 'net/http'


def handle(event:, context:)
  slack_event = Pokebot::Lambda::Event.slack_api_event(event)

  Pokebot::Service::Message::Controller.call(slack_event)

  return slack_event['http_response']
end
