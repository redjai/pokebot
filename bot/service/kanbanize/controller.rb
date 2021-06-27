require_relative 'import_board_activities' # change this name
require_relative 'board_activities_imported' # change this name

module Service
  module Kanbanize
    module Controller
      extend self

      def call(bot_request)
        case bot_request.data['action']
        when Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES 
          Service::Kanbanize::ImportBoardActivities.call(bot_request) # change this name
        else
          Bot::LOGGER.error "unexpected action #{bot_request.data['action']}"
        end
      end
    end
  end
end
