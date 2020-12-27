require 'json'
require 'pokebot/sns'
require 'pokebot/data'

def handle(event:, context:)
    puts event
    slack_data = http_event_data(event)

    puts slack_data
    
    if challenged?(slack_data)
      return plain_text_respond(slack_data['challenge'])
    end
    
    unless authenticated?(event)
      return plain_text_respond('Not authorized', 401)
    end

    event_data = { "slack" => slack_data }
    topic.publish(message: event_data.to_json) 
end

def challenged?(slack_data)
  slack_data['challenge']   
end

def authenticated?(event)
  slack_signed_secret(event) == signature(event)
end

def slack_signed_secret(event)
  event['headers']["x-slack-signature"]
end

def slack_request_timestamp(event)
  event['headers']["x-slack-request-timestamp"]
end

def signature(event) 
  "v0=#{OpenSSL::HMAC.hexdigest("SHA256", ENV['SLACK_SIGNED_SECRET'], base(event))}"
end

def base(event)
  "v0:#{slack_request_timestamp(event)}:#{event['body']}"
end

def plain_text_respond(body, status_code=200)
  { statusCode: status_code, headers: {"Content-Type" => 'text/plain'} }
end
