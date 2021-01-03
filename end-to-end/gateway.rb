require 'json'
require 'pokebot/topic/sns'
require 'pokebot/lambda/event'
require 'pokebot/lambda/http_response'
require 'pokebot/slack/authentication'

def handle(event:, context:)
  pokebot_data = Pokebot::Lambda::Event.from_slack_event(event)
  
  if pokebot_data['slack']['challenge']
    return Pokebot::Lambda::HttpResponse.plain_text(pokebot_data['slack']['challenge'])
  end
 
  unless Pokebot::Slack::Authentication.authenticated?(
           timestamp: event['headers']['x-slack-request-timestamp'],
           signature: event['headers']['x-slack-signature'],
           body: event['body']
        )
    return Pokebot::Lambda::HttpResponse.plain_text('Not authorized', 401)
  end
  
  Pokebot::Topic::Sns.topic.publish(message: pokebot_data.to_json) 
end

