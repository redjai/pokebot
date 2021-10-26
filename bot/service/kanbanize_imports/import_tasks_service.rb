require 'date'
require 'aws-sdk-s3'
require_relative '../kanbanize/net/api'
require 'storage/kanbanize/dynamodb/client'
require 'storage/kanbanize/s3/task'
require 'gerty/request/events/kanbanize'
require 'storage/kanbanize/dynamodb/tasks'

# this service imports task details for any new activities found that day
module Service
  module Kanbanize
    module ImportTasks
      extend self
      extend Service::Kanbanize::Api
      extend Storage::Kanbanize::DynamoDB::Client
                                  
      def listen
        [
          Gerty::Request::Events::Kanbanize::TASKS_FOUND,
          Gerty::Request::Events::Kanbanize::ARCHIVED_TASKS_FOUND
        ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])

        collection = bot_request.data['activities'] ||  bot_request.data['tasks']
        
        ids = collection.collect do |activity|
          activity['taskid']
        end.uniq # lets not import the same task multiple times if there is more than one activity.

        puts ids.inspect

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
          Storage::Kanbanize::DynamoDB::Task.upsert(client_id: client.id, task: task)
        end

        bot_request.events << Gerty::Request::Events::Kanbanize.tasks_imported(
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
