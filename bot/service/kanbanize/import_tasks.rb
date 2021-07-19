require 'date'
require 'aws-sdk-s3'
require_relative 'net/api'
require 'storage/kanbanize/client'
require 'storage/kanbanize/task'

module Service
  module Kanbanize
    module ImportTasks # change this name 
      extend self
      extend Service::Kanbanize::Api
      extend Storage::Kanbanize

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])
        
        ids = bot_request.data['activities'].collect do |activity|
          activity['taskid']
        end.uniq

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
          store.store!(task)
        end
        
        bot_request.current = ::Request::Events::Kanbanize.tasks_imported(
          source: self.class.name, 
          client_id: client.id, 
          board_id: bot_request.data['board_id'],
          tasks: ids.collect{ |id| { "task_id" => id } } 
        )

        Topic::Sns.broadcast(
          topic: :kanbanize,
          request: bot_request
        ) 
      end
    end
  end
end
