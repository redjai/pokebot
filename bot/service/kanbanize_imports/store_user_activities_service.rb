require 'gerty/request/events/kanbanize'
require 'date'
require 'storage/dynamodb/kanbanize/activities'

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

        new_activities = Storage::DynamoDB::Kanbanize::Activities.upsert( team_id: bot_request.data['team_id'], 
                                                                           board_id: bot_request.data['board_id'], 
                                                                         activities: bot_request.data['activities'] )
      
        if new_activities.any?
          bot_request.events << Gerty::Request::Events::Kanbanize.new_activities_found(
                                source: self.class.name, 
                                team_id: bot_request.data['team_id'],
                                board_id: bot_request.data['board_id'],
                                activities: new_activities
                              )                  
        end
      end
    end
  end
end
  
