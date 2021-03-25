require 'topic/sns'
require 'handlers/lambda/http_response'
require 'slack/authentication'
require 'topic/topic'

module Service
  module Message 
    module Search
      def self.call(bot_request)

        bot_request.current = Topic::Messages.received(source: :messages, text: text(bot_request)) 

        Topic::Sns.broadcast(
            topic: :messages,
            event: bot_request
        )
      end

      def self.text(bot_request)
        bot_request.current['data']['event']['text'].gsub(/<[^>]+>/,"").strip
      end
    end
  end
end
