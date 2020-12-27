require 'net/http'
require 'uri'
require 'json'


POST_MESSAGE_URI = URI.parse("https://slack.com/api/chat.postMessage")

class SlackFailure < StandardError ; end 

def respond_to_slack(channel:, text:)
  result = JSON.parse(Net::HTTP.post(POST_MESSAGE_URI, { channel: channel, text: text }.to_json , header).body)
  raise SlackFailure, result['error'] unless result['ok']
end

def header
  {
    'Content-Type' => 'application/json',
    'Accepts' => 'text/plain',
    'Authorization' => "Bearer #{token}"
  }
end

def token
  ENV['BOT_USER_OAUTH_ACCESS_TOKEN']
end
