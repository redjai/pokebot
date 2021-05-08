require 'topic/sns'
require 'topic/topic'
require 'topic/topic'
require 'topic/topic'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_request)
        case bot_request.data['type']
        when 'block_actions'
          block_actions(bot_request)
        when 'view_submission'
          
        end
      end

      def block_actions(bot_request)
        bot_request.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            bot_request.current = Topic::Users.favourite_new(source: :interaction, favourite_recipe_id: value['data']) 

            Topic::Sns.broadcast(topic: :users, request: bot_request)
          when 'unfavourite'
            bot_request.current = Topic::Users.favourite_destroy(source: :interaction, favourite_recipe_id: value['data']) 

            Topic::Sns.broadcast(topic: :users, request: bot_request)
          when 'next-recipes' 
            bot_request.current = Topic::Recipes.search_requested(source: :interaction, 
                                                                           query: value['data']['query'],
                                                                           offset: value['data']['offset'],
                                                                           per_page: value['data']['per_page']
                                                                         )
            Topic::Sns.broadcast(topic: :recipes, request: bot_request)
          when 'edit-account'
            bot_request.current = Topic::Users.account_edit_requested(source: :interactions) 
            Topic::Sns.broadcast(topic: :users, request: bot_request)
          end
        end
      end

      def view_submission(bot_request)
        case bot_request.context.private_metadata
        when
          bot_request.current = Topic::Users.account_update_requested(source: :interactions, state: bot_request.data['state']) 
          Topic::Sns.broadcast(topic: :users, request: bot_request)
        end
      end
    end
  end
end
