require 'pokebot/topic/sns'
require 'pokebot/lambda/http_response'
require_relative 'search'

module Pokebot
  module Service
    module Message 
      module Controller
        def self.call(bot_event)
          Pokebot::Service::Message::Search.call(bot_event)
        end
      end
    end
  end
end
