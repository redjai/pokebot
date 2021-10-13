require 'date'
require 'aws-sdk-s3'
require_relative '../kanbanize/net/api'
require 'storage/kanbanize/dynamodb/client'
require 'storage/kanbanize/s3/task'
require 'request/events/kanbanize'

# this service imports task details for any new activities found that day
module Service
  module Kanbanize
    module ImportTasks
      extend self
      extend Service::Kanbanize::Api
      extend Storage::Kanbanize::DynamoDB
                                  
      def listen
        [
          Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND,
          Request::Events::Kanbanize::TASKS_FOUND,
          Request::Events::Kanbanize::ARCHIVED_TASKS_FOUND
        ]
      end

      def broadcast
        %w( kanbanize )
      end

      Service::BoundedContext.register(self)

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])

        collection = bot_request.data['activities'] ||  bot_request.data['tasks']
        
        ids = collection.collect do |activity|
          activity['taskid']
        end.uniq # lets not import the same task multiple times if there is more than one activity.

        uri = uri(subdomain: client.subdomain, function: :get_task_details)  

        response = post(
          kanbanize_api_key: client.kanbanize_api_key, 
          uri: uri,
          body: {
            board_id: bot_request.data['board_id'],
            taskid: ids,
            history: 'yes'
          } 
        )

        response = response.is_a?(Hash) ? [response] : response

        store = Storage::Kanbanize::TaskStore.new(
          bot_request.data['client_id'],
          bot_request.data['board_id'],
        )

        response.each do |task|
          case bot_request.data['archived']
          when 'yes'
            store.archive!(task)
          else
            store.store!(task)
          end
        end
        
        bot_request.events << ::Request::Events::Kanbanize.tasks_imported(
          source: self.class.name, 
          client_id: client.id, 
          board_id: bot_request.data['board_id'],
          tasks: ids.collect{ |id| { "task_id" => id } },
          archived: bot_request.data['archived'] ? 'yes' : 'no'  
        )
      end
    end
  end
end
