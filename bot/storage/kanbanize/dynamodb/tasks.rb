require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
      module Task
        extend self

        class TaskData

          def initialize(client_id:, kanbanize_data:)
            @kanbanize_data = kanbanize_data
            @client_id = client_id
          end

          def history_details
            @kanbanize_data['historydetails'].sort_by{ |history_detail| history_detail['historyid'] }
          end

          def created_at
            DateTime.parse(history_details.first['entrydate']).iso8601
          end

          def updated_at
            DateTime.parse(history_details.last['entrydate']).iso8601
          end

          def hydrate!
            @kanbanize_data['id'] = "#{@client_id}-#{@kanbanize_data['taskid']}"
            @kanbanize_data['client_id'] = @client_id
          end

          def data
            hydrate!
            @kanbanize_data
          end

        end

        class HistoryDetail

          def initialize(client_id, kanbanize_data)
            @kanbanize_data = kanbanize_data
            @client_id = client_id
          end

          def item
            @kanbanize_data.merge({'id' => id, 'entrydate' => entrydate})
          end

          def id
            "#{@client_id}-#{@kanbanize_data['historyid']}"
          end

          def entrydate
            DateTime.parse(@kanbanize_data['entrydate']).iso8601
          end 

        end
          
        @@dynamo_resource = nil 
        
        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
        end

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end
        
        def upsert(client_id:, task:)
          task_data = TaskData.new(client_id: client_id, kanbanize_data: task)
          dynamo_resource.client.put_item(
            {
              item: task_data.data,
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME']
            }
          )

          items = task_data.history_details.collect do |history_detail|
            {
              put_request: {
                item: HistoryDetail.new(client_id, history_detail).item
              }
            }
          end
          
          items.each_slice(25) do |slice| # maximum 25 items in a batch write

            request = {
              request_items: {
                ENV['KANBANIZE_HISTORY_DETAILS_TABLE_NAME'] => slice
              }
            }
 
            dynamo_resource.client.batch_write_item(request)
          end
        end


        #TODO: drop tasks table and make id the primary key not taskid
        def test2
          ids = ['livelink-2381', 'livelink-2382']
          dynamo_resource.client.batch_get_item(
            request_items: {
              ENV['KANBANIZE_TASKS_TABLE_NAME'] => {
                keys: ids.collect{ |id| { "taskid" => id } },
              }
            }
          )
        end

        def test
          dynamo_resource.client.query(
            {
              expression_attribute_values: {
                ":created_at" => "2021-10-01",
                ":client_id" => "livelink"
              },
               expression_attribute_names: {
                "#created_at" => "created_at",
                "#client_id" => "client_id"
              },
              key_condition_expression: "#created_at > :created_at AND #client_id = :client_id",
              index_name: "created_at",
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME'], 
            }
          )
        end
        
      end 
    end
  end
end