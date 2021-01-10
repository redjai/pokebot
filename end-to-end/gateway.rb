require 'pokebot/topic/sns'
require 'pokebot/lambda/event'
require 'pokebot/lambda/http_response'
require 'pokebot/slack/authentication'

def handle(event:, context:)
  slack_request_data = Pokebot::Lambda::Event.from_slack_event(event)
  
  if slack_request_data['slack']['challenge']
    return Pokebot::Lambda::HttpResponse.plain_text(slack_request_data['slack']['challenge'])
  end
 
  unless Pokebot::Slack::Authentication.authenticated?(
           timestamp: event['headers']['x-slack-request-timestamp'],
           signature: event['headers']['x-slack-signature'],
           body: event['body']
        )
    return Pokebot::Lambda::HttpResponse.plain_text('Not authorized', 401)
  end
  
  Pokebot::Topic::Sns.broadcast(
    topic: :messages, 
    event: Pokebot::Lambda::Event::MESSAGE_RECEIVED, 
    state: slack_request_data
  ) 
end

