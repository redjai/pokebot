require 'aws-sdk-dynamodb'
require 'gerty/lib/logger'
require 'date'

require_relative '../lib/named_cycle'

module Service
  module Insight
    module Storage
      module NamedCycles
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

        def active_cycles(team_id:, board_id:, date: Date.today)
          active_cycle_ids(team_id: team_id, board_id: board_id, date: date).collect do |id|
            item = dynamo_resource.client.get_item({
              key: {
                "team_board_id" => team_board_id(team_id: team_id, board_id: board_id),
                "name" => id['name']
              }, 
              table_name: ENV['INSIGHTS_NAMED_CYCLES_TABLE_NAME'],
            })[:item]
            named_cycle_from_item(item)
          end
        end

        def named_cycle(team_id:, board_id:, name:)
          named_cycle_ids(team_id: team_id, board_id: board_id, name: name).collect do |id|
            item = dynamo_resource.client.get_item({
              key: {
                "team_board_id" => team_board_id(team_id: team_id, board_id: board_id),
                "name" => id['name']
              }, 
              table_name: ENV['INSIGHTS_NAMED_CYCLES_TABLE_NAME'],
            })[:item]
            named_cycle_from_item(item)
          end.first
        end

        def named_cycle_from_item(item)
          Service::Insight::NamedCycle.new( team_board_id: item['team_board_id'], 
                                                     name: item['name'], 
                                            next_cycle_at: item['next_cycle_at'],
                                                     from: item['from'],
                                                       to: item['to'] )
        end

        def named_cycle_ids(team_id:, board_id:, name:)
          dynamo_resource.client.query({
            table_name: ENV['INSIGHTS_NAMED_CYCLES_TABLE_NAME'], # required
            index_name: 'team_board_id_name',
            key_condition_expression: "#team_board_id = :team_board_id AND #name = :name",
            expression_attribute_names: {
              '#team_board_id' => 'team_board_id',
              '#name' => 'name'
            },
            expression_attribute_values: {
              ':team_board_id' => team_board_id(team_id: team_id, board_id: board_id),
              ':name' => name
            }
          })[:items]
        end

        def active_cycle_ids(team_id:, board_id:, date:)
          dynamo_resource.client.query({
            table_name: ENV['INSIGHTS_NAMED_CYCLES_TABLE_NAME'], # required
            index_name: 'team_board_id_next_cycle_at',
            key_condition_expression: "#team_board_id = :team_board_id AND #next_cycle_at < :next_cycle_at",
            expression_attribute_names: {
              '#team_board_id' => 'team_board_id',
              '#next_cycle_at' => 'next_cycle_at'
            },
            expression_attribute_values: {
              ':team_board_id' => team_board_id(team_id: team_id, board_id: board_id),
              ':next_cycle_at' => date.to_datetime.iso8601
            }
          })[:items]
        end

        def team_board_id(team_id:, board_id:)
          "#{team_id}-#{board_id}"
        end

        def set_next_cycle_at(named_cycle)     
          dynamo_resource.client.update_item(
            {
              key: {
                "team_board_id" => named_cycle.team_board_id,
                "name" => named_cycle.name
              },  
              update_expression: 'SET #next_cycle_at = :next_cycle_at',
              expression_attribute_names: {
                '#next_cycle_at': 'next_cycle_at'
              },
              expression_attribute_values: {
                ':next_cycle_at': named_cycle.next_cycle_at
              },
              table_name: ENV['INSIGHTS_NAMED_CYCLES_TABLE_NAME']
            }
          ) 
        end

      end
    end
  end
end
      