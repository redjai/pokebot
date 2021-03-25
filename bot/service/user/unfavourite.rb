require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative 'user'
require 'topic/topic'

module Service
  module User
    module Unfavourite 
      extend self

      def call(bot_request)
        updates = Service::User::User.destroy(bot_request.slack_user['slack_id'], bot_request.data['favourite_recipe_id']) 
        puts ">>>" + updates.inspect
        bot_request.current = Topic::Users.favourites_updated(source: :user, 
                                                     favourite_recipe_ids: updates['attributes']['favourites'].collect{|id| id })
        Topic::Sns.broadcast(
                                topic: :user,
                                event: bot_request
                            )
      end
    end
  end
end

