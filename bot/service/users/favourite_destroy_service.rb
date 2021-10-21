require 'aws-sdk-dynamodb'
require 'storage/kanbanize/dynamodb/user_favourites'
require 'gerty/request/events/users'
require 'gerty/service/bounded_context'

module Service
  module User
    module Favourite
      module Remove
      extend self

        def listen
          [ Gerty::Request::Events::Users::FAVOURITE_DESTROY ]
        end

        def broadcast
          [ :users ]
        end

        Gerty::Service::BoundedContext.register(self)

        def call(bot_request)
          updates = Storage::Kanbanize::DynamoDB::UserFavourites.remove_favourite(
                                                                   team_id: bot_request.context.team_id,
                                                                  slack_id: bot_request.context.slack_id, 
                                                                 recipe_id: bot_request.data['favourite_recipe_id']
                                                                )
          recipe_ids =  (updates['attributes'] || {}).fetch('favourites',[]).collect{|id| id }
          bot_request.events << Gerty::Request::Events::Users.favourites_updated( source: :user, 
                                                               favourite_recipe_ids: recipe_ids )
        end
      end
    end
  end
end

