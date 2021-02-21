require 'topic/sns'
require 'lambda/http_response'
require_relative 'search'

module Service
  module Message 
    module Controller
      def self.call(bot_event)
        Service::Message::Search.call(bot_event)
      end
    end
  end
end
