require 'aws-sdk-dynamodb'
require 'gerty/lib/logger'

module Service
  module Kanbanize
    module Storage
      module Task
        extend self
          
        @@dynamo_resource = nil 
    
        def dynamo_resource
          @@dynamo_resource ||= Aws::DynamoDB::Resource.new(options)
        end

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end

        PROJECTIONS = {
          basic: "taskid,boardid,title"
        }

        def fetch_all(team_id, task_ids, projection: :basic)
          dynamo_resource.batch_get_item({
            request_items: {
              ENV['KANBANIZE_TASKS_TABLE_NAME'] => {
                keys: task_ids.collect do |task_id|
                  {
                    id: "#{team_id}-#{task_id}" 
                  }
                end.uniq,
                projection_expression: PROJECTIONS[projection] 
              }, 
            }
          }).responses[ENV['KANBANIZE_TASKS_TABLE_NAME']]
        end
        
        def upsert(task_data)
          
          dynamo_resource.client.put_item(
            {
              item: task_data.item,
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME']
            }
          )
          
        end

      end 
    end
  end
end