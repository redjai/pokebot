require 'pokebot/lambda/event'
require 'pokebot/slack/response'

def handle(event:, context:)
  Pokebot::Lambda::Event.each_sqs_record_data(event) do |pokebot_data|
    Pokebot::Slack::Response.respond(
      channel: pokebot_data['slack']['event']['channel'], 
      text: pokebot_data['responses']['text']
    )
  end 
end


