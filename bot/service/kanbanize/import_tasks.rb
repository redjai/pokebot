require 'date'
require 'aws-sdk-s3'
require_relative 'api'
require_relative 'client'

module Service
  module Kanbanize
    module ImportTasks # change this name 
      extend self
      extend Service::Kanbanize::Api
      extend Service::Kanbanize::Storage

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])
        
        ids = bot_request.data['activities'].collect do |activity|
          activity['taskid']
        end

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

        tasks = Tasks.new(
          bot_request.data['client_id'],
          bot_request.data['board_id'],
          response
        )

        tasks.store!
      end

      class Tasks

        def initialize(client_id, board_id, tasks)
          @client_id = client_id
          @board_id = board_id
          @tasks = tasks
        end

        def store!
          @tasks.each do |task|
            object = bucket.object(key(task['taskid'])) 
            object.put(body: task.to_json)
          end
        end

        def resource 
          @resource ||= Aws::S3::Resource.new(region: ENV['REGION'])
        end

        def bucket
          resource.bucket(ENV['KANBANIZE_IMPORTS_BUCKET'])
        end

        def key(task_id)
          File.join("tasks", @client_id, @board_id, "#{task_id}.json")
        end

      end
    end
  end
end
