require 'gerty/request/events/kanbanize'
require 'date'
require 'storage/kanbanize/dynamodb/activities'

# all of todays activities are imported in 'import board activities'
# this service saves these to s3 IF they haven't already been saved in an earlier request today
# it then broadcasts any new activities imported. 
module Service
  module Kanbanize
    module StoreUserActivities # change this name 
      extend self
                                
      def listen
        [ Gerty::Request::Events::Kanbanize::ACTIVITIES_IMPORTED ]
      end

      def broadcast
        %w( kanbanize users )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)

        activities = bot_request.data['activities']

        puts Storage::Kanbanize::DynamoDB::Activities.yesterday(author: "Ben")
            
        if activities.any?

          Storage::Kanbanize::DynamoDB::Activities.upsert(client_id: bot_request.data['client_id'],
                                                         board_id: bot_request.data['board_id'],
                                                         activities: activities)

          bot_request.events << Gerty::Request::Events::Kanbanize.new_activities_found(
                                source: self.class.name, 
                                client_id: bot_request.data['client_id'],
                                board_id: bot_request.data['board_id'],
                                activities: activities
                              )
                              
        end
      end

    end
  end
end
  
