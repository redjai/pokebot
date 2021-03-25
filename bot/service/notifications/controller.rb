require 'slack/response'
require 'topic/topic'

module Service
  module Notifications 
    module Controller
      def self.call(bot_request)
        case bot_request.name
        when Topic::Users::FAVOURITES_UPDATED
          Slack::Response.notify_channel(channel: 'pokebot_tester', text: 'favourites updated')
        end
      end
    end
  end
end
