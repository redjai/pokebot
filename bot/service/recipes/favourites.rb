require 'aws-sdk-dynamodb'
require_relative 'user'

module Service
  module Recipe 
    module Favourite 
      extend self

      def call(bot_request)
        Service::Recipe::User.upsert(bot_request.context.slack_id, bot_request.data['favourite_recipe_ids'])
      end

    end
  end
end
