require 'date'
require 'aws-sdk-s3'
require_relative '../kanbanize/net/api'
require 'storage/kanbanize/dynamodb/team'
require 'gerty/request/events/kanbanize'

require_relative 'find_tasks/active_tasks'

#
# fetches the task ids of active and archived tasks for a board
#

module Service
  module Kanbanize
    module FindTaskIdsForBoards
      extend self
      extend Storage::Kanbanize::DynamoDB::Team

      def listen
        [ Gerty::Request::Events::Cron::Actions::FIND_TASK_IDS_FOR_BOARDS ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self) 

      def call(bot_request)
        get_teams.each do |team|

          team.board_ids.each do |board_id|
            bot_request.events << ActiveTasks.new( team_id: team.team_id, 
                                                    board_id: board_id,
                                                    api_key: team.kanbanize_api_key,
                                                  subdomain: team.subdomain ).tasks_found_event
                  
          end
        end
      end
    end
  end
end
