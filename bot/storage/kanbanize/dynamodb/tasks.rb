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

          def id
            "#{@client_id}-#{@kanbanize_data['taskid']}"
          end

          def hydrate!
            @kanbanize_data['id'] = id
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

        PROJECTIONS = {
          basic: "Title"
        }

        

        def fetch(**args)

          if args[:client_id] && args[:task_id]
            id = "#{args[:client_id]}-#{args[:task_id]}"
          elsif

          Storage::Kanbanize::DynamoDB::Client::Client.new(
            dynamo_resource.client.get_item({
              key: {
                "id" => 
              },
              projection_expression: PROJECTIONS[projection], 
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME'],
            })[:item]
          )
        end
        
        def upsert(client_id:, task:)
          task_data = TaskData.new(client_id: client_id, kanbanize_data: task)
          dynamo_resource.client.put_item(
            {
              item: task_data.data,
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME']
            }
          )

          task_data.history_details.each do |history_detail|
            store_history_detail(client_id: client_id, history_detail: history_detail)
          end
        end

        def store_history_detail(client_id:, history_detail:)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['KANBANIZE_HISTORY_DETAILS_TABLE_NAME'],
              item: HistoryDetail.new(client_id, history_detail).item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
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