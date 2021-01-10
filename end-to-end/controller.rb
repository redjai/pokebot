require 'pokebot/topic/sns'
require 'pokebot/lambda/event'

def handle(event:, context:)
  puts event

  Pokebot::Lambda::Event.each_sqs_record_pokebot_event(event) do |pokebot_event|
    next unless pokebot_event['event'] == Pokebot::Lambda::Event::MESSAGE_RECEIVED
    user = pokebot_event['state']['slack']['event']['user'] # the user id provided to us in the original POST from slack.
    user_message = pokebot_event['state']['slack']['event']['text']
    pokebot_event['state']['responses'] = { 'text' => "<@#{user}> hello from pokebot, you said '#{user_message}'" }
    Pokebot::Topic::Sns.broadcast(
      topic: :responses, 
      event: Pokebot::Lambda::Event::POKEBOT_RESPONSE_RECEIVED,  
      state: pokebot_event['state']
    )
  end 
end


