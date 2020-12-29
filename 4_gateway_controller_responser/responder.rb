require 'bot/aws/event'
require 'bot/slack/response'

def handle(event:, context:)
  Bot::Aws::Event.record_data(event) do |pokebot_data|
    Bot::Slack::Response.respond(
      channel: pokebot_data['slack']['event']['channel'], 
      text: pokebot_data['responses']['text']
    )
  end 
end


