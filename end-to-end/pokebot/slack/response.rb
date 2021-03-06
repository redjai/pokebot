require 'net/http'
require 'uri'
require 'json'

module Pokebot
  module Slack
    module Response
      extend self

      POST_MESSAGE_URI = URI.parse("https://slack.com/api/chat.postMessage")

      class Failure < StandardError ; end 

      def respond(channel:, text:)
        result = JSON.parse(Net::HTTP.post(POST_MESSAGE_URI, { channel: channel, text: text }.to_json , header).body)
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
end
