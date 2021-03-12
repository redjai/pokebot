require 'net/http'
require 'uri'
require 'json'

module Slack
  module Response
    extend self

    POST_MESSAGE_URI = URI.parse("https://slack.com/api/chat.postMessage")
    DELETE_MESSAGE_URI = URI.parse("https://slack.com/api/chat.delete")

    class Failure < StandardError ; end 

    def delete(channel:, ts:)
      data = { channel: channel, ts: ts }
      result = JSON.parse(Net::HTTP.post(DELETE_MESSAGE_URI, data.to_json , header).body)
      puts result
      raise Failure, result['error'] unless result['ok']
    end

    def respond(channel:, text:, blocks: nil, response_url: nil)
      data = { channel: channel, text: text }
      data[:blocks] = blocks if blocks
      uri = response_url ?  URI.parse(response_url) : POST_MESSAGE_URI
      result = JSON.parse(Net::HTTP.post(uri, data.to_json , header).body)
      puts result
      raise Failure, result['error'] unless result['ok']
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

  end
end
