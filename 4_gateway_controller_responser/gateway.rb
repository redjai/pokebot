require 'json'
require 'bot/aws/sns'
require 'bot/aws/event'
require 'bot/aws/http_response'
require 'bot/slack/authentication'

def handle(event:, context:)
  pokebot_data = {} 
  pokebot_data['slack'] = Bot::Aws::Event.http_data(event)

  
  if pokebot_data['slack']['challenge']
    return Bot::Aws::HttpResponse.plain_text(pokebot_data['slack']['challenge'])
  end
 
  unless Bot::Slack::Authentication.authenticated?(
           timestamp: event['headers']['x-slack-request-timestamp'],
           signature: event['headers']['x-slack-signature'],
           body: event['body']
        )
    return Bot::Aws::HttpResponse.plain_text('Not authorized', 401)
  end
  
  Bot::Aws::Sns.topic.publish(message: pokebot_data.to_json) 
end

