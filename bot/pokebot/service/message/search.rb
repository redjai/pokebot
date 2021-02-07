require 'pokebot/topic/sns'
require 'pokebot/lambda/http_response'
require 'pokebot/slack/authentication'

module Pokebot
  module Service
    module Message 
      module Search
        def self.call(message_event)
          Pokebot::Topic::Sns.broadcast(
            topic: :messages, 
            event: Pokebot::Lambda::Event::MESSAGE_RECEIVED, 
            state: message_event.state
          )
        end
      end
    end
  end
end
