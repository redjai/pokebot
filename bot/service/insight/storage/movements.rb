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

        def fetch(team_id:, board_id:, from_column_name:, to_column_name:, start_date:, end_date:)
          ids = dynamo_resource.client.query({
            table_name: ENV['INSIGHTS_MOVEMENTS_TABLE_NAME'], # required
            index_name: "team_board_id_from_to_date",
            key_condition_expression: "#team_board_id_from_to = :team_board_id_from_to AND #date BETWEEN :after AND :before",
            expression_attribute_names: {
              '#team_board_id_from_to' => 'team_board_id_from_to',
              '#entry_at' => 'entry_at'
            },
            expression_attribute_values: {
              ':team_board_id_from_to' => "#{team_id}-#{board_id}-#{from_column_name}-#{to_column_name}",
              ':after' => start_date.to_datetime.iso8601,
              ':before' => end_date.to_datetime.iso8601
            }
          })
        end
      end
    end
  end
end