require 'topic/sns'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_event)
        bot_event.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            Topic::Sns.broadcast(
                                   topic: :interactions, 
                                   source: :interaction,
                                   name: Bot::Event::FAVOURITE_NEW,
                                   version: 1.0,
                                   event: bot_event,
                                   data: { 
                                     favourite_id: value['data'], 
                                     user: { 
                                       slack_id: bot_event.data['user']['id'], 
                                       channel: bot_event.data['container']['channel_id'] 
                                     } 
                                   }
                                 )
          else
            puts "unknown interaction"
            puts action.inspect
          end
        end
      end
    end
  end
end
