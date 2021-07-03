require 'date'
require 'aws-sdk-s3'
require_relative 'api'
require_relative 'client'

module Service
  module Kanbanize
    module ImportAllTasks # change this name 
      extend self
      extend Service::Kanbanize::Api
      extend Service::Kanbanize::Storage

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])
        
        uri = uri(subdomain: client.subdomain, function: :get_all_tasks)  

        response = post(
          kanbanize_api_key: client.kanbanize_api_key, 
          uri: uri,
          body: {
            boardid: bot_request.data['board_id']
          } 
        )

        response = response.is_a?(Hash) ? [response] : response

        bot_request.current = ::Request::Events::Kanbanize.new_activities_found(
          client_id: bot_request.data['client_id'],
          source: self.class.name, 
          board_id: bot_request.data['board_id'], 
          activities: response.collect{ |task| { "taskid" => task['taskid']} }
        )

        Topic::Sns.broadcast(
          topic: :kanbanize,
          request: bot_request
        )
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
