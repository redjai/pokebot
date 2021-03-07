require 'topic/sns'
require 'lambda/http_response'
require 'slack/authentication'
require 'bot/event_builders'

module Service
  module Message 
    module Search
      def self.call(bot_event)

        bot_event.current = Bot::EventBuilders.message_received(source: :messages, text: text(bot_event)) 

        Topic::Sns.broadcast(
            topic: :messages,
            event: bot_event
        )
      end

      def self.text(bot_event)
        bot_event.current['data']['event']['text'].gsub(/<[^>]+>/,"").strip
      end
    end
  end
end
