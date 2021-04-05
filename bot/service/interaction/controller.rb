require 'topic/sns'
require 'topic/topic'
require 'topic/topic'
require 'topic/topic'

module Service
  module Interaction
    module Controller
      extend self

      def call(bot_request)
        bot_request.data['actions'].each do |action|
          value = JSON.parse(action['value'])
          case value['interaction']
          when 'favourite'
            bot_request.intent = Topic::Users.favourite_new(source: :interaction, favourite_recipe_id: value['data']) 

            Topic::Sns.broadcast(topic: :users, event: bot_request)
          when 'unfavourite'
            bot_request.intent = Topic::Users.favourite_destroy(source: :interaction, favourite_recipe_id: value['data']) 

            Topic::Sns.broadcast(topic: :users, event: bot_request)
          when 'next-recipes' 
            bot_request.intent = Topic::Recipes.search_requested(source: :interaction, 
                                                                           query: value['data']['query'],
                                                                           offset: value['data']['offset'],
                                                                           per_page: value['data']['per_page']
                                                                         )
            Topic::Sns.broadcast(topic: :recipes, event: bot_request)
          when 'edit-account'
            bot_request.intent = Topic::Users.account_edit(source: :interactions) 
            Topic::Sns.broadcast(topic: :users, event: bot_request)
          end

        end
      end
    end
  end
end
