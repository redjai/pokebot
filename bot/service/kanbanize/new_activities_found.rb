require 'request/events/kanbanize'
require 'topic/sns'
require 'date'
require 'storage/kanbanize/activity'

module Service
  module Kanbanize
    module NewActivitiesFound # change this name 
      extend self

      def call(bot_request)
        store = Storage::Kanbanize::ActivityStore.new(
          bot_request.data['client_id'], 
          bot_request.data['board_id'],  
        )

        new_activities  = bot_request.data['activities'].select do |activity|
          store.store!(activity)
        end
            
      
        if new_activities.any?

          bot_request.current = Request::Events::Kanbanize.new_activities_found(
                                source: self.class.name, 
                                client_id: bot_request.data['client_id'],
                                board_id: bot_request.data['board_id'],
                                activities: new_activities
                              )

          Topic::Sns.broadcast(
            topic: [:kanbanize, :users],
            request: bot_request
          )
        end
      end

    end
  end
end

