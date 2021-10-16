require 'date'
require 'aws-sdk-s3'
require_relative '../kanbanize/net/api'
require 'storage/kanbanize/dynamodb/client'
require 'gerty/request/events/kanbanize'

require_relative 'find_tasks/active_tasks'
require_relative 'find_tasks/archived_tasks'

#
# fetches the task ids of active and archived tasks for a board
#

module Service
  module Kanbanize
    module FindTasks
      extend self
      extend Storage::Kanbanize::DynamoDB

      def listen
        [ Gerty::Request::Events::Kanbanize::FIND_TASK_IDS_FOR_BOARD ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self) 

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])

        client.board_ids.each do |board_id|
          event = if bot_request.data['archive']
            ArchiveTasks.new(client_id: client.id, 
                             board_id: board_id,
                             api_key: client.kanbanize_api_key,
                             subdomain: client.subdomain,  
                             date_range: bot_request.data['archive']).tasks_found_event
          else
            ActiveTasks.new(client_id: client.id, 
                      board_id: board_id,
                      api_key: client.kanbanize_api_key,
                      subdomain: client.subdomain).tasks_found_event        
          end
          bot_request.events << event
        end
    
      end
    end
  end
end
