require 'request/events/cron'
require 'request/events/kanbanize'

module Service
  module Kanbanize
    module Controller
      extend self

      def call(bot_request)
        if bot_request.name == Request::Events::Cron::SCHEDULED_REQUEST
          case bot_request.data['action']
          when Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES 
            require_relative 'import_board_activities' # change this name
            Service::Kanbanize::ImportBoardActivities.call(bot_request) # change this name
          else
            Bot::LOGGER.error "unexpected action #{bot_request.data['action']}"
          end
        else
          case bot_request.name
          when Request::Events::Kanbanize::ACTIVITIES_IMPORTED
            require_relative 'new_activities_found' 
            Service::Kanbanize::NewActivitiesFound.call(bot_request)
          else
            Bot::LOGGER.error "unexpected action #{bot_request.name}"
          end
        end
      end
    end
  end
end
