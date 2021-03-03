require 'aws-sdk-dynamodb'
require_relative 'user'

module Service
  module Recipe 
    module Favourite 
      extend self

      def call(bot_event)
        Service::Recipe::User.upsert(bot_event.slack_user['slack_id'], bot_event.data['favourite_recipe_ids'])
      end

    end
  end
end
