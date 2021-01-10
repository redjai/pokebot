require 'pokebot/lambda/event'
require 'pokebot/slack/response'

def handle(event:, context:)
  Pokebot::Lambda::Event.each_sqs_record_pokebot_event(event) do |pokebot_event|
    puts pokebot_event
    next unless pokebot_event['event'] == Pokebot::Lambda::Event::POKEBOT_RESPONSE_RECEIVED
    Pokebot::Slack::Response.respond(
      channel: pokebot_event['state']['slack']['event']['channel'], 
      text: pokebot_event['state']['responses']['text']
    )
  end 
end


