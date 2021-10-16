require 'aws-sdk-dynamodb'
require_relative 'storage/favourites'
require 'gerty/request/events/users'
require 'service/bounded_context'

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

        Service::BoundedContext.register(self)

        def call(bot_request)
          updates = Service::User::Storage.remove_favourite(bot_request.context.slack_id, bot_request.data['favourite_recipe_id'])
          recipe_ids =  (updates['attributes'] || {}).fetch('favourites',[]).collect{|id| id }
          bot_request.events << Gerty::Request::Events::Users.favourites_updated( source: :user, 
                                                               favourite_recipe_ids: recipe_ids )
        end
      end
    end
  end
end

