require 'net/http'
require 'uri'
require 'json'

module Service
  module Responder
    module Slack
      module Response
        extend self

        POST_MESSAGE_URI = URI.parse("https://slack.com/api/chat.postMessage")
        DELETE_MESSAGE_URI = URI.parse("https://slack.com/api/chat.delete")
        NOTIFICATION_URI = URI.parse("https://hooks.slack.com/services/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e")
        VIEWS_OPEN_URI = URI.parse('https://slack.com/api/views.open')

        class Failure < StandardError
          attr_accessor :context
          def initialize(message, context=nil)
            super(message)
            @context = context
          end
        end 

        def delete(channel:, ts:)
          data = { channel: channel, ts: ts }
          result = JSON.parse(Net::HTTP.post(DELETE_MESSAGE_URI, data.to_json , header).body)
          raise Failure, result['error'] unless result['ok']
        end

        # can respond to any request in any channel
        def respond(channel:, text:, blocks: nil, response_url: nil)
          data = { channel: channel, text: text }
          data[:blocks] = blocks if blocks
          uri = response_url ?  URI.parse(response_url) : POST_MESSAGE_URI
          result = Net::HTTP.post(uri, data.to_json , header).body
          unless result == "ok"
            JSON.parse(result)
            raise Failure.new(result['error'], data) unless result['ok']
          end
        end

        # notify users in a specific channel set up with a webhook URI
        def notify_channel(channel:, text:)
          data = { channel: channel, text: text }
          uri = URI.parse(ENV["#{channel.to_s.upcase}_NOTIFICATION_URI"])
          result = JSON.parse(Net::HTTP.post(uri, data.to_json , header).body)
          raise Failure.new(result['error'], data) unless result['ok']
        end

        def modal(trigger_id, view)
          uri = VIEWS_OPEN_URI
          data = { trigger_id: trigger_id, view: view }
          result = JSON.parse(Net::HTTP.post(uri, data.to_json, header).body)
          raise Failure.new(result['error'], data) unless result['ok']
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
end