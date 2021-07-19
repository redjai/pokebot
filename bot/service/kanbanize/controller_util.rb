require 'request/events/cron'
require 'request/events/kanbanize'

module Service
  module Kanbanize
    module ControllerUtil
      extend self

      def call(bot_request)
        case bot_request.data['action']
        when Request::Events::Util::Actions::IMPORT_ALL_TASKS
          require_relative 'import_all_tasks' # change this name
          Service::Kanbanize::ImportAllTasks.call(bot_request) # change this name
        when Request::Events::Util::Actions::DB_MIGRATE
          require_relative 'db_migrate' # change this name
          Service::Kanbanize::DbMigrate.call(bot_request) # change this name
        else
          Bot::LOGGER.error "unexpected action #{bot_request.data['action'].to_s}"
        end
      end
    end
  end
end
