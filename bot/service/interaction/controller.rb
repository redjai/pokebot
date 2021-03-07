require 'bot/topic/sns'
require 'bot/event_builders'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_request)
        bot_request.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            bot_request.current = Bot::EventBuilders.favourite_search_requested(source: :interaction) 

            Topic::Sns.broadcast(topic: :interactions, event: bot_request)
          else
            bot_request.current = Bot::EventBuilders.more_search_results_requested(source: :interaction, 
                                                                                 query: value['data']['query'],
                                                                                    ts: bot_request.data['container']['message_ts'])
            Topic::Sns.broadcast(
                                   topic: :interactions, 
                                   event: bot_request
                                 )

          end
        end
      end
    end
  end
end
