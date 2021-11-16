require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
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
        
        def upsert(team_id:, task:)
          task_data = TaskData.new(team_id: team_id, kanbanize_data: task)
          dynamo_resource.client.put_item(
            {
              item: task_data.data,
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME']
            }
          )

          task_data.history_details.each do |history_detail|
            store_history_detail(team_id: team_id, history_detail: history_detail)
          end

          task_data.column_stays.values.each do |column_stay|
            store_column_stay(column_stay)
          end
        end

        def store_history_detail(team_id:, history_detail:)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_HISTORY_DETAILS_TABLE_NAME'],
              item: HistoryDetail.new(team_id, history_detail).item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end

        def store_column_stay(column_stay)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_COLUMN_STAYS_TABLE_NAME'],
              item: column_stay.item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end

        def store_movement(movement)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_MOVEMENTS_TABLE_NAME'],
              item: column_stay.item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end

        def store_section_stay(section_stay)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_SECTION_STAYS_TABLE_NAME'],
              item: section_stay.item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end  
      end 
    end
  end
end