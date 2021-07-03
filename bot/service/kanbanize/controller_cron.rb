require 'request/events/cron'
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
        else
          Bot::LOGGER.error "unexpected action #{bot_request.data['action']}"
        end
      end
    end
  end
end
