require 'json'

def handle(event:, context:)
  puts event

  slack_data = http_event_data(event)

  if slack_data['challenge']
    puts 401
    return plain_text_response(slack_data['challenge'])
  end

  puts 200

  return plain_text_response('hello pokebot')
end

def http_event_data(aws_event)
  body(aws_event)
end

def data(aws_event)
  JSON.parse(body(aws_event))
end

def body(aws_event)
  if aws_event["isBase64Encoded"]
    require 'base64'
    Base64.decode64(aws_event['body'])
  else
    aws_event['body']
  end
end

def plain_text_response(body, status_code=200)
  { 
    body: body, 
    statusCode: status_code, 
    headers: {"content-type" => "text/plain"} 
  }
end

def authenticated?(event)
  slack_signed_secret(event) == signature(event)
end

def slack_signed_secret(event)
  event['headers']["x-slack-signature"]
end

def signature(event)
  "v0=#{OpenSSL::HMAC.hexdigest(
         "SHA256",
         ENV['SLACK_SIGNED_SECRET'],
         base(event)
       )}"
end

def base(event)
  "v0:#{event['x-slack-request-timestamp']}:#{event['body']}"
end
