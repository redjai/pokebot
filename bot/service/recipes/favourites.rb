require 'aws-sdk-dynamodb'
require_relative 'user'
require 'gerty/service/bounded_context'
require 'gerty/request/events/users'

module Service
  module Recipe 
    module Favourite 
      extend self

      def listen
        [ Gerty::Request::Events::Users::FAVOURITES_UPDATED ]
      end

      def broadcast
        []
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        Service::Recipe::User.upsert(bot_request.context.slack_id, bot_request.data['favourite_recipe_ids'])
      end

    end
  end
end
