require 'json'

def handle(event:, context:)
    puts event

    slack_data = event_body(event)

    if challenged?(slack_data)
      return respond(slack_data['challenge'])
    end

    unless authenticated?(event)
      puts "401"
      return respond('Not authorized', 401)
    end

    puts "200"

    return respond('hello pokebot')
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

def signature(event) 
  "v0=#{OpenSSL::HMAC.hexdigest("SHA256", ENV['SLACK_SIGNED_SECRET'], base(event))}"
end

def base(event)
  "v0:#{Time.now.to_i}:#{event['body']}"
end

