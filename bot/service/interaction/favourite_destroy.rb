require 'topic/sns'
require 'gerty/request/events/users'
require 'gerty/request/events/recipes'
require_relative 'view_submissions/user_account_update_requested'

module Service
  module Interaction
    module FavouriteDestroy
      extend self

      def listen
        [ Gerty::Request::Events::Slack::INTERACTION_API_REQUEST ]
      end

      def broadcast
        [ :users ]
      end

      Service::BoundedContext.register(self)

      def call(bot_request)
        if bot_request.data['type'] == 'block_actions'
          value = JSON.parse(bot_request.data['actions'].first['value'])
          if value['interaction'] == 'unfavourite'
            bot_request.events << Gerty::Request::Events::Users.favourite_destroy(source: :interaction, favourite_recipe_id: value['data']) 
          end
        end
      end
    end
  end
end