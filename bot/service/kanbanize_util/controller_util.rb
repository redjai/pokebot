require 'gerty/request/events/cron'
require 'gerty/request/events/kanbanize'

module Service
  module Kanbanize
    module ControllerUtil
      extend self

      def call(bot_request)
        case bot_request.data['action']
        when Gerty::Request::Events::Util::Actions::FIND_TASKS
          require_relative 'find_tasks' # change this name
          Service::Kanbanize::FindTasks.call(bot_request) # change this name
        when Gerty::Request::Events::Util::Actions::DB_MIGRATE
          require_relative 'db_migrate' # change this name
          Service::Kanbanize::DbMigrate.call(bot_request) # change this name
        else
          Bot::LOGGER.error "unexpected action #{bot_request.data['action'].to_s}"
        end
      end
    end
  end
end
