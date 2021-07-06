require 'date'
require 'aws-sdk-s3'
require_relative 'api'
require_relative 'client'

module Service
  module Kanbanize
    module ImportAllTasks # change this name 
      extend self
      extend Service::Kanbanize::Storage

      def call(bot_request)
        client = get_client(bot_request.data['client_id'])
 
        tasks = if bot_request.data['archive']
          ArchiveTasks.new(client, bot_request)
        else
          Tasks.new(client, bot_request)        
        end
      
        Topic::Sns.broadcast(
          topic: :kanbanize,
          request: tasks.new_activities_found 
        )
      end

      class TaskBase
        include Service::Kanbanize::Api

        def initialize(client, bot_request)
          @client = client
          @bot_request = bot_request
        end

        def get_all_tasks_uri
          uri(subdomain: @client.subdomain, function: :get_all_tasks)
        end

        def taskids
          response.collect{ |task| { "taskid" => task['taskid']} }
        end

        def new_activities_found
          @bot_request.current = ::Request::Events::Kanbanize.new_activities_found(
            client_id: @bot_request.data['client_id'],
            source: self.class.name, 
            board_id: @bot_request.data['board_id'], 
            activities: taskids
          )
          @bot_request
        end
      end

      class ArchiveTasks < TaskBase
        
        DEFAULT_PAGE_SIZE = 30

        def response
          page = 1
          tasks = []
          loop do
            body = body(page)
            result = post(kanbanize_api_key: @client.kanbanize_api_key, uri: get_all_tasks_uri, body: body)
            tasks += result['task']
            break unless result["numberoftasks"].to_i > page.to_i * page_size.to_i
            page += 1
          end
          tasks 
        end

        def page_size
          ENV['PAGE_SIZE'] || DEFAULT_PAGE_SIZE
        end

        def body(page)
          dates = @bot_request.data['archive'].split(":")
          {
             boardid: @bot_request.data['board_id'],
             fromdate: dates.first, 
             todate: argdate(Date.parse(dates.last) + 1),
             container: 'archive',
             page: page
          }
        end

      end

      class Tasks < TaskBase
        include Service::Kanbanize::Api

        def initialize(client, bot_request)
          @client = client
          @bot_request = bot_request
        end


        def response
          [
            post(
              kanbanize_api_key: @client.kanbanize_api_key, 
              uri: get_all_tasks_uri,
              body: body 
            )
          ].flatten
        end

        def body
          {
             boardid: @bot_request.data['board_id']
          }
        end

        def new_activities_found
          @bot_request.current = ::Request::Events::Kanbanize.new_activities_found(
            client_id: @bot_request.data['client_id'],
            source: self.class.name, 
            board_id: @bot_request.data['board_id'], 
            activities: taskids
          )
          @bot_request
        end

      end
    end
  end
end
