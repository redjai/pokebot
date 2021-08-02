require 'request/events/cron'
require 'request/events/util'
require 'request/events/kanbanize'

module Service
  module Kanbanize
    module ControllerCron
      extend self

      def call(bot_request)
        case bot_request.data['action']
        when Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES 
          require_relative 'import_board_activities' # change this name
          Service::Kanbanize::ImportBoardActivities.call(bot_request) # change this name
        when Request::Events::Util::Actions::FIND_TASKS
          require_relative 'find_tasks'
          Service::Kanbanize::FindTasks.call(bot_request)
        else
          Bot::LOGGER.error "unexpected action #{bot_request.data['action']}"
        end
      end
    end
  end
end
