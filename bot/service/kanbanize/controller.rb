require 'request/events/cron'
require 'request/events/kanbanize'

module Service
  module Kanbanize
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when Request::Events::Kanbanize::ACTIVITIES_IMPORTED
          require_relative 'new_activities_found' 
          Service::Kanbanize::NewActivitiesFound.call(bot_request)
        when Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND,
             Request::Events::Kanbanize::TASKS_FOUND,
             Request::Events::Kanbanize::ARCHIVED_TASKS_FOUND
          require_relative 'import_tasks' 
          Service::Kanbanize::ImportTasks.call(bot_request)
        when Request::Events::Kanbanize::TASKS_IMPORTED
          require_relative 'task_column_duration'
          Service::Kanbanize::TaskColumnDuration.call(bot_request)
        else
          Bot::LOGGER.error "unexpected action #{bot_request.name}"
        end
      end
    end
  end
end
