require 'topic/sns'
require 'bot/event_builders'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_event)
        bot_event.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            bot_event.current = Bot::EventBuilders.favourite_search_requested(source: :interaction) 

            Topic::Sns.broadcast(topic: :interactions, event: bot_event)
          else
            bot_event.current = Bot::EventBuilders.more_search_results_requested(source: :interaction, 
                                                                                 query: value['data']['query'],
                                                                                    ts: bot_event.data['container']['message_ts'])
            Topic::Sns.broadcast(
                                   topic: :interactions, 
                                   event: bot_event
                                 )

          end
        end
      end
    end
  end
end
