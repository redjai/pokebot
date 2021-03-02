require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative 'user'

module Service
  module User
    module Favourite 
      extend self

      def call(bot_event)
        updates = Service::User::User.upsert(bot_event.slack_user['slack_id'], bot_event.data['favourite_recipe_id']) 
        if updates
          bot_event.current = Bot::EventBuilders.favourites_updated(source: :user, 
                                                     favourite_recipe_ids: updates['attributes']['favourites'].collect{|id| id })
          Topic::Sns.broadcast(
                                topic: :user,
                                event: bot_event
                              )
        end
      end
    end
  end
end

