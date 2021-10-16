require 'aws-sdk-dynamodb'
require_relative 'storage/favourites'
require 'request/events/users'
require 'service/bounded_context'

module Service
  module User
    module Favourite 
      module Add
      extend self

        def listen
          [ ::Request::Events::Users::FAVOURITE_NEW ]
        end

        def broadcast
          [ :users ]
        end

        Service::BoundedContext.register(self)

        def call(bot_request)
          updates = Service::User::Storage.add_favourite(bot_request.context.slack_id, bot_request.data['favourite_recipe_id'])
          recipe_ids = updates['attributes']['favourites'].collect{|id| id }
          if updates
            bot_request.events << ::Request::Events::Users.favourites_updated( source: :user, 
                                                                 favourite_recipe_ids: recipe_ids )
          end
        end
      end
    end
  end
end

