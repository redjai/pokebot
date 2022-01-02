require 'gerty/request/events/kanbanize'
require_relative 'task_base' 

module Service
  module Kanbanize
    module Api
      class ActiveTasks < TaskBase
        include Service::Kanbanize::Api

        def response
          [
            post(
              kanbanize_api_key: @api_key, 
              uri: get_all_tasks_uri,
              body: body 
            )
          ].flatten
        end

        def body
          {
            boardid: @board_id
          }
        end

        def tasks_found_event
          if any?
            Gerty::Request::Events::Kanbanize.tasks_found(
              team_id: @team_id,
              source: self.class.name, 
              board_id: @board_id, 
              tasks: taskids
            )
          end
        end
      end
    end
  end
end