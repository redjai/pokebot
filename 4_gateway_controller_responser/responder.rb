require 'bot/aws/event'
require 'bot/slack/response'

def handle(event:, context:)
  event["Records"].each do |record|
    pokebot_data = Bot::Aws::Event.sqs_record_data(record)
    Bot::Slack::Response.respond(
      channel: pokebot_data['slack']['event']['channel'], 
      text: pokebot_data['responses']['text']
    )
  end 
end


