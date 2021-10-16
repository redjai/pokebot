require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Kanbanize 
        extend self
        extend Gerty::Request::Base

        FIND_TASK_IDS_FOR_BOARD = 'find_task_ids_for_board'
        ACTIVITIES_IMPORTED = 'activities_imported'
        TASKS_IMPORTED = 'tasks_imported'
        NEW_ACTIVITIES_FOUND = 'new_activities_found'
        ARCHIVED_TASKS_FOUND = 'archived_tasks_found'
        TASKS_FOUND = 'tasks_found'
        
        def activities_imported(source:, client_id:, board_id:, activities:)
          data = {
            'board_id' => board_id,
            'client_id' => client_id,
            'activities' => activities
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Kanbanize::ACTIVITIES_IMPORTED, version: 1.0, data: data)      
        end
        
        def new_activities_found(source:, client_id:, board_id:, activities:)
          data = {
            'board_id' => board_id,
            'client_id' => client_id,
            'activities' => activities
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND, version: 1.0, data: data)      
        end

        def tasks_found(source:, client_id:, board_id:, tasks:)
          data = {
            'board_id' => board_id,
            'client_id' => client_id,
            'tasks' => tasks
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Kanbanize::TASKS_FOUND, version: 1.0, data: data)      
        end

        def archived_tasks_found(source:, client_id:, board_id:, tasks:)
          data = {
            'board_id' => board_id,
            'client_id' => client_id,
            'tasks' => tasks,
            'archived' => 'yes'
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Kanbanize::ARCHIVED_TASKS_FOUND, version: 1.0, data: data)      
        end
        
        def tasks_imported(source:, client_id:, board_id:, tasks:, archived: 'no')
          data = {
            'board_id' => board_id,
            'client_id' => client_id,
            'tasks' => tasks,
            'archived' => archived
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Kanbanize::TASKS_IMPORTED, version: 1.0, data: data)      
        end
      end
    end
  end
end