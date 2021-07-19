require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative '../storage'
require 'request/events/users'

module Service
  module User
    module Favourite 
      module Add
      extend self

        def call(bot_request)
          updates = Service::User::Storage.add_favourite(bot_request.context.slack_id, bot_request.data['favourite_recipe_id']) 
          if updates
            bot_request.current = ::Request::Events::Users.favourites_updated(source: :user, 
                                                       favourite_recipe_ids: updates['attributes']['favourites'].collect{|id| id })
            Topic::Sns.broadcast(
                                  topic: :users,
                                  request: bot_request
                                )
          end
        end
      end
    end
  end
end

