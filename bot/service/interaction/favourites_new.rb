require 'gerty/request/events/users'
require 'gerty/request/events/recipes'
require_relative 'view_submissions/user_account_update_requested'

module Service
  module Interaction
    module FavouriteNew
      extend self

      def listen
        [ Gerty::Request::Events::Slack::INTERACTION_API_REQUEST ]
      end

      def broadcast
        [ :users ]
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        if bot_request.data['type'] == 'block_actions'
          value = JSON.parse(bot_request.data['actions'].first['value'])
          if value['interaction'] == 'favourite'
            bot_request.events << Gerty::Request::Events::Users.favourite_new(source: :interaction, favourite_recipe_id: value['data']) 
          end
        end
      end
    end
  end
end
