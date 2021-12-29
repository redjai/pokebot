require 'date'
require 'aws-sdk-s3'
require_relative '../kanbanize/net/api'
require 'storage/dynamodb/team'
require 'gerty/request/events/cron'

require_relative 'find_tasks/archived_tasks'

#
# fetches the task ids of active and archived tasks for a board
#

module Service
  module Kanbanize
    module FindArchiveTaskIdsForBoards
      extend self
      extend Storage::Kanbanize::DynamoDB::Team

      def listen
        [ Gerty::Request::Events::Cron::Actions::FIND_ARCHIVE_TASK_IDS_FOR_BOARDS ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self) 

      def call(bot_request)
        get_teams.each do |team|
          team.board_ids.each do |board_id|
            bot_request.events  << ArchiveTasks.new(   team_id: team.team_id, 
                                                      board_id: board_id,
                                                       api_key: team.kanbanize_api_key,
                                                     subdomain: team.subdomain,  
                                                    date_range: bot_request.data['archive']).tasks_found_event
          end
        end
      end
    end
  end
end
