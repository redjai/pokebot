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

        def fetch_from(team_id:, board_id:, from:, before:, after:)
          items = fetch_items(
                           team_id: team_id,
                          board_id: board_id,
                        from_or_to: :from,
                            column: from,
                            before: before,
                             after: after
                          ) 
           movements_from_items(team_id: team_id, board_id: board_id, items: items)
        end
  
        def fetch_to(team_id:, board_id:, to:, before:, after:)
          items = fetch_items(
                           team_id: team_id,
                          board_id: board_id,
                        from_or_to: :to,
                            column: to,
                            before: before,
                             after: after
                          )
          movements_from_items(team_id: team_id, board_id: board_id, items: items)
        end
    
        private
  
        def movements_from_items(team_id:, board_id:, items:)
          items.collect do |item|
            Movement.from_item(team_id: team_id, board_id: board_id, item: item)
          end
        end
        
        def fetch_items(team_id:, board_id:, from_or_to:, column:,  before:, after:)
          ids = fetch_item_ids(team_id: team_id, board_id: board_id, from_or_to: from_or_to, column: column,  before: before, after: after)
          if ids.empty?
            Gerty::LOGGER.debug("no movements found #{team_id} #{board_id} #{from_or_to} #{column} #{before} #{after}")
            []
          else
            ids.collect do |id|
              dynamo_resource.client.get_item({
                table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'],
                key: { "id" => id }
              })[:item]
            end
          end
        end
 
        def fetch_item_ids(team_id:, board_id:, from_or_to:, column:,  before:, after:)
          dynamo_resource.client.query({
            table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'], # required
            index_name: "team_board_id_#{from_or_to}_date",
            key_condition_expression: "#team_board_id_from_or_to = :team_board_id_from_or_to AND #date BETWEEN :after AND :before",
            expression_attribute_names: {
              '#team_board_id_from_or_to' => "team_board_id_#{from_or_to}",
              '#date' => 'date'
            },
            expression_attribute_values: {
              ':team_board_id_from_or_to' => "#{team_id}-#{board_id}-#{column.downcase}",
              ':after' => after.to_datetime.iso8601,
              ':before' => before.to_datetime.iso8601
            }
          })[:items].collect{ |item| item['id'] }
        end
      end
    end
  end
end


