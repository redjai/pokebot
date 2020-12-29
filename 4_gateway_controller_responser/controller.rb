require 'json'
require 'bot/aws/sns'
require 'bot/aws/event'

def handle(event:, context:)
  puts event

  event["Records"].each do |record|
    pokebot_data = Bot::Aws::Event.sqs_record_data(record)
    user = pokebot_data['slack']['event']['user'] # the user id provided to us in the original POST from slack.
    user_message = pokebot_data['slack']['event']['text']
    pokebot_data['responses'] = { 'text' => "<@#{user}> hello from pokebot, you said '#{user_message}'" }
    Bot::Aws::Sns.topic.publish(message: pokebot_data.to_json)
  end 
end


