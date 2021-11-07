require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
      module Task
        extend self

        class TaskData

          def initialize(team_id:, kanbanize_data:)
            @kanbanize_data = kanbanize_data
            @team_id = team_id
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
            "#{@team_id}-#{@kanbanize_data['taskid']}"
          end

          def hydrate!
            @kanbanize_data['id'] = id
            @kanbanize_data['team_id'] = @team_id
          end

          def data
            hydrate!
            @kanbanize_data
          end

        end

        class HistoryDetail

          def initialize(team_id, kanbanize_data)
            @kanbanize_data = kanbanize_data
            @team_id = team_id
          end

          def item
            @kanbanize_data.merge({'id' => id, 'entrydate' => entrydate})
          end

          def id
            "#{@team_id}-#{@kanbanize_data['historyid']}"
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
                ":team_id" => "livelink"
              },
               expression_attribute_names: {
                "#created_at" => "created_at",
                "#team_id" => "team_id"
              },
              key_condition_expression: "#created_at > :created_at AND #team_id = :team_id",
              index_name: "created_at",
              table_name: ENV['KANBANIZE_TASKS_TABLE_NAME'], 
            }
          )
        end
        
      end 
    end
  end
end