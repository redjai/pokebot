require 'topic/sns'
require 'handlers/processors/http_response'
require 'slack/authentication'
require 'request/events/message'

module Service
  module Message 
    module Search
      def self.call(bot_request)

        bot_request.current = ::Request::Events::Messages.received(source: :messages, text: text(bot_request)) 

        Topic::Sns.broadcast(
            topic: :messages,
            request: bot_request
        )
      end

      def self.text(bot_request)
        bot_request.current['data']['event']['text'].gsub(/<[^>]+>/,"").strip
      end
    end
  end
end
