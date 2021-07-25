require 'date'
require 'aws-sdk-s3'
require_relative 'net/api'
require 'storage/kanbanize/dynamodb/client'

module Service
  module Kanbanize
    module FindTasks
      extend self
      extend Storage::Kanbanize::DynamoDB

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
            Tasks.new(client_id: client.id, 
                      board_id: board_id,
                      api_key: client.kanbanize_api_key,
                      subdomain: client.subdomain).tasks_found_event        
          end
          bot_request.events << event
        end
    
        Topic::Sns.broadcast(
          topic: :kanbanize,
          request: bot_request
        )
      end

      class TaskBase
        include Service::Kanbanize::Api

        def initialize(client_id:, board_id:, api_key:, subdomain:)
          @client_id = client_id
          @board_id = board_id
          @api_key = api_key
          @subdomain = subdomain
        end

        def get_all_tasks_uri
          uri(subdomain: @subdomain, function: :get_all_tasks)
        end

        def taskids
          @task_ids ||= response.collect{ |task| { "taskid" => task['taskid']} }
        end

        def any?
          taskids.any?
        end
      end

      class ArchiveTasks < TaskBase
        
        DEFAULT_PAGE_SIZE = 30

        def initialize(client_id:, board_id:, api_key:, subdomain:, date_range:)
          super(client_id: client_id, board_id: board_id, api_key: api_key, subdomain: subdomain)
          @date_range = date_range
        end

        def tasks_found_event
          if any?
            ::Request::Events::Kanbanize.archived_tasks_found(
              client_id: @client_id,
              source: self.class.name, 
              board_id: @board_id, 
              tasks: taskids
            )
          end
        end

        def response
          page = 1
          tasks = []
          loop do
            body = body(page)
            result = post(kanbanize_api_key: @api_key, uri: get_all_tasks_uri, body: body)
            break if result == []
            tasks += result['task']
            break unless result["numberoftasks"].to_i > page.to_i * page_size.to_i
            page += 1
          end
          tasks 
        end

        def page_size
          ENV['PAGE_SIZE'] || DEFAULT_PAGE_SIZE
        end

        def dates
          @dates ||= date_range(@date_range)
        end

        def body(page)
          {
             boardid: @board_id,
             fromdate: dates[:from], 
             todate: dates[:to],
             container: 'archive',
             page: page
          }
        end

      end

      class Tasks < TaskBase
        include Service::Kanbanize::Api

        def response
          [
            post(
              kanbanize_api_key: @api_key, 
              uri: get_all_tasks_uri,
              body: body 
            )
          ].flatten
        end

        def body
          {
             boardid: @board_id
          }
        end

        def tasks_found_event
          if any?
            ::Request::Events::Kanbanize.tasks_found(
              client_id: @client_id,
              source: self.class.name, 
              board_id: @board_id, 
              tasks: taskids
            )
          end
        end
      end
    end
  end
end
