require 'json'
require 'pokebot/topic/sns'
require 'pokebot/lambda/event'

def handle(event:, context:)
  puts event

  Pokebot::Lambda::Event.each_sqs_record_data(event) do |pokebot_data|
    user = pokebot_data['slack']['event']['user'] # the user id provided to us in the original POST from slack.
    user_message = pokebot_data['slack']['event']['text']
    pokebot_data['responses'] = { 'text' => "<@#{user}> hello from pokebot, you said '#{user_message}'" }
    Pokebot::Topic::Sns.topic.publish(message: pokebot_data.to_json)
  end 
end


