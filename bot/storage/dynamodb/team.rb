require 'aws-sdk-dynamodb'

module Storage
  module DynamoDB
    module Team
    extend self

      class Team

        def initialize(data)
          @team = data
        end

        def kanbanize_api_key
          @team['kanbanize_api_key']
        end

        def subdomain
          @team['subdomain']
        end

        def team_id
          @team['team_id']
        end

        def board_ids 
          @team['board_ids'].sort
        end

        def last_board_id
          @team['last_board_id'] || board_ids.last
        end

        def board_id
          board_ids[board_ids.index(last_board_id) + 1] || board_ids.first
        end

        def firehoses
          @team['firehose']
        end

        def blockages_channel
          @team['blockages_channel']
        end

        def team_id
          @team['team_id']
        end

      end

      @@dynamo_resource = nil 
      
      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
      end

      def create(team_id:, board_ids:, kanbanize_api_key:, subdomain:)
        dynamo_resource.client.put_item(
          {
            item: {
              "team_id" => team_id,
              "board_ids" => board_ids,
              "kanbanize_api_key" => kanbanize_api_key,
              "subdomain" => subdomain 
            },
            table_name: ENV['KANBANIZE_TEAMS_TABLE_NAME']
          }
        ) 
      end

      def set_last_board(team_id, board_id)
        dynamo_resource.client.update_item(
          {
            key: {
              "team_id" => team_id 
            },  
            update_expression: 'SET #last_board_id = :board_id',
            expression_attribute_names: {
              '#last_board_id': 'last_board_id'
            },
            expression_attribute_values: {
              ':board_id': board_id
            },
            table_name: ENV['KANBANIZE_TEAMS_TABLE_NAME'],
          }
        ) 
      end

      def get_teams
        ENV['TEAM_IDS'].split(",").collect do |team_id|
          get_team(team_id)
        end
      end

      def get_team(team_id)
        Storage::DynamoDB::Team::Team.new(
          dynamo_resource.client.get_item({
            key: {
              "team_id" => team_id 
            }, 
            table_name: ENV['KANBANIZE_TEAMS_TABLE_NAME'],
          })[:item]
        )
      end

      def options
        { region: ENV['REGION'] }.tap do |opts|
          opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
          opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
        end
      end
    end
  end
end
