require 'topic/sns'
require 'topic/events/users'
require 'topic/events/recipes'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_request)
        bot_request.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            bot_request.current = Topic::Events::Users.favourite_new(source: :interaction, favourite_recipe_id: value['data']) 

            Topic::Sns.broadcast(topic: :users, event: bot_request)
          else
            bot_request.current = Topic::Events::Recipes.more_search_results_requested(source: :interaction, 
                                                                                    query: value['data']['query'],
                                                                                       ts: bot_request.data['container']['message_ts'])
            Topic::Sns.broadcast(topic: :recipes, event: bot_request)
          end
        end
      end
    end
  end
end
