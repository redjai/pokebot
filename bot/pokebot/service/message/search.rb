require 'pokebot/topic/sns'
require 'pokebot/lambda/http_response'
require 'pokebot/slack/authentication'

module Pokebot
  module Service
    module Message 
      module Search
        def self.call(bot_event)
          Pokebot::Topic::Sns.broadcast(
              topic: :messages,
             source: :messages,
               name: Bot::Event::MESSAGE_RECEIVED,
            version: 1.0, 
              event: bot_event,
               data: data(bot_event)
          )
        end

        def self.data(bot_event)
          { 
            text: bot_event.current['data']['event']['text'].gsub(/<[^>]+>/,"").strip,
            user: {
              slack_id: bot_event.current['data']['event']['user'], 
               channel: bot_event.current['data']['event']['channel']
            }
          }
        end
      end
    end
  end
end
