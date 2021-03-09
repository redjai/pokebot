require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative 'user'
require 'topic/events/users'

module Service
  module User
    module Favourite 
      extend self

      def call(bot_request)
        updates = Service::User::User.upsert(bot_request.slack_user['slack_id'], bot_request.data['favourite_recipe_id']) 
        if updates
          bot_request.current = Topic::Events::Users.favourites_updated(source: :user, 
                                                     favourite_recipe_ids: updates['attributes']['favourites'].collect{|id| id })
          Topic::Sns.broadcast(
                                topic: :user,
                                event: bot_request
                              )
        end
      end
    end
  end
end

