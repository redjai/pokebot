require 'gerty/request/events/kanbanize'
require 'date'
require 'storage/kanbanize/s3/board_activity_store'

# all of todays activities are imported in 'import board activities'
# this service saves these to s3 IF they haven't already been saved in an earlier request today
# it then broadcasts any new activities imported. 
module Service
  module Kanbanize
    module StoreBoardActivities # change this name 
      extend self
                                
      def listen
        [ Gerty::Request::Events::Kanbanize::ACTIVITIES_IMPORTED ]
      end

      def broadcast
        %w( kanbanize users )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        store = Storage::Kanbanize::BoardActivityStore.new(
          bot_request.data['team_id'], 
          bot_request.data['board_id'],  
        )

        new_activities  = bot_request.data['activities'].select do |activity|
          store.store!(activity)
        end
            
      
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
  
