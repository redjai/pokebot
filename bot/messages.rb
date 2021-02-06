require 'pokebot/lambda/event'
require 'pokebot/service/message'
require 'net/http'


def handle(event:, context:)
  slack_event = Pokebot::Lambda::Event.slack_api_event(event)

  Pokebot::Service::Message.call(slack_event)

  return slack_event['http_response']
end

