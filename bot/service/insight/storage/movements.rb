require 'aws-sdk-dynamodb'
require 'gerty/lib/logger'

module Service
  module Insight
    module Storage
      module Movements
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

        def store(movement)
          begin
            dynamo_resource.client.put_item({
              table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'],
              item: movement.item,
              condition_expression: "attribute_not_exists(id)"
            }).successful?
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException => e
            Gerty::LOGGER.debug(e)
            false
          end
        end

        def fetch_exit_named_movements(team_id:, board_id:, exit:, before:, after:)
          exit_movement_ids = ExitNamedMovementIds.new(
                              client: dynamo_resource.client,
                             team_id: team_id,
                            board_id: board_id,
                                exit: exit,
                              before: before,
                               after: after
                            ).ids

          Movements.new( 
                         team_id: team_id,
                        board_id: board_id,
                          client: dynamo_resource.client 
                       ).from_ids(exit_movement_ids)
        end

        def fetch_entry_named_movements(team_id:, board_id:, task_ids:, entry:)
          entry_movement_ids = EntryNamedMovementIds.new(
                                    client: dynamo_resource.client,
                                   team_id: team_id,
                                  board_id: board_id,
                                     entry: entry,
                                  task_ids: task_ids
                                  ).ids

           Movements.new( 
                          team_id: team_id,
                          board_id: board_id,
                            client: dynamo_resource.client 
                        ).from_ids(entry_movement_ids)
        end

        def fetch_entry_indexed_movements(team_id:, board_id:, task_ids:, index:)
          entry_movement_ids = EntryIndexedMovementIds.new(
                                    client: dynamo_resource.client,
                                   team_id: team_id,
                                  board_id: board_id,
                                  task_ids: task_ids,
                                     index: index
                                  ).ids

           Movements.new( 
                          team_id: team_id,
                          board_id: board_id,
                            client: dynamo_resource.client 
                        ).from_ids(entry_movement_ids)
        end
 
        class Movements

          attr_accessor :team_id, :board_id, :client

          def initialize(client:, team_id:, board_id:)
            @team_id = team_id
            @board_id = board_id
            @client = client
          end

          def from_ids(ids)
            ids.collect do |id|
              from_item(movement_item(id))
            end
          end

          private
  
          def from_item(item)
            Movement.from_item(team_id: team_id, board_id: board_id, item: item)
          end
  
          def movement_item(id)
            client.get_item({
              table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'],
              key: { "id" => id }
            })[:item]
          end
  
        end

        class EntryNamedMovementIds 

          def initialize(client:, team_id:, board_id:, task_ids:, entry:)
            @team_id = team_id
            @board_id = board_id
            @client = client
            @task_ids = task_ids
            @entry = entry
          end

          def ids
            @task_ids.collect do |task_id|
              id(task_id)
            end.compact
          end

          def id(task_id)
            ids = @client.query({
              table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'], # required
              index_name: "team_board_id_task_id_to",
              key_condition_expression: "#team_board_id_to = :team_board_id_to AND #task_id = :task_id",
              expression_attribute_names: {
                '#team_board_id_to' => "team_board_id_to",
                '#task_id' => 'task_id'
              },
              expression_attribute_values: {
                ':team_board_id_to' => "#{@team_id}-#{@board_id}-#{@entry.downcase}",
                ':task_id' => task_id
              }
            })[:items].collect{ |item| item['id'] }

            # return nil unless we have exactly one result
            ids.first if ids.length == 1
          end

        end

        class EntryIndexedMovementIds 

          def initialize(client:, team_id:, board_id:, task_ids:, index:)
            @team_id = team_id
            @board_id = board_id
            @client = client
            @task_ids = task_ids
            @index = index
          end

          def ids
            @task_ids.collect do |task_id|
              id(task_id)
            end.compact
          end

          def id(task_id)
            ids = @client.query({
              table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'], # required
              index_name: "task_id_index",
              key_condition_expression: "#index = :index AND #task_id = :task_id",
              expression_attribute_names: {
                '#index' => "index",
                '#task_id' => 'task_id'
              },
              expression_attribute_values: {
                ':index' => @index,
                ':task_id' => task_id
              }
            })[:items].collect{ |item| item['id'] }

            # return nil unless we have exactly one result
            ids.first if ids.length == 1
          end

        end

        class ExitNamedMovementIds
          
          def initialize(client:, team_id:, board_id:, exit:, before:, after:)
            @team_id = team_id
            @board_id = board_id
            @client = client
            @exit = exit
            @before = before
            @after = after
          end
  
          def ids
            @client.query({
              table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'], # required
              index_name: "team_board_id_from_date",
              key_condition_expression: "#team_board_id_from = :team_board_id_from AND #date BETWEEN :after AND :before",
              expression_attribute_names: {
                '#team_board_id_from' => "team_board_id_from",
                '#date' => 'date'
              },
              expression_attribute_values: {
                ':team_board_id_from' => "#{@team_id}-#{@board_id}-#{@exit.downcase}",
                ':after' => @after.to_datetime.iso8601,
                ':before' => @before.to_datetime.iso8601
              }
            })[:items].collect{ |item| item['id'] }
          end
        end

      end
    end
  end
end


