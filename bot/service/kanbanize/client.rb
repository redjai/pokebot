require 'aws-sdk-dynamodb'
require 'topic/sns'

module Service
  module Kanbanize 
    module Storage 
      extend self

      class Client

        def initialize(data)
          @client = data
        end

        def kanbanize_api_key
          @client['kanbanize_api_key']
        end

        def subdomain
          @client['subdomain']
        end

        def id
          @client['client_id']
        end

        def board_ids 
          @client['board_ids'].sort
        end

        def last_board_id
          @client['last_board_id'] || board_ids.last
        end

        def board_id
          board_ids[board_ids.index(last_board_id) + 1] || board_ids.first
        end

      end

      @@dynamo_resource = nil 
      
      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
      end

      def create_client(client_id, board_ids, kanbanize_api_key, subdomain)
        dynamo_resource.client.put_item(
          {
            item: {
              "client_id" => client_id,
              "board_ids" => board_ids,
              "kanbanize_api_key" => kanbanize_api_key,
              "subdomain" => subdomain 
            },
            table_name: ENV['KANBANIZE_CLIENTS_TABLE_NAME']
          }
        ) 
      end

      def set_last_board(client_id, board_id)
        dynamo_resource.client.update_item(
          {
            key: {
              "client_id" => client_id 
            },  
            update_expression: 'SET #last_board_id = :board_id',
            expression_attribute_names: {
              '#last_board_id': 'last_board_id'
            },
            expression_attribute_values: {
              ':board_id': board_id
            },
            table_name: ENV['KANBANIZE_CLIENTS_TABLE_NAME'],
          }
        ) 
      end 

      def get_client(client_id)
        Service::Kanbanize::Storage::Client.new(
          dynamo_resource.client.get_item({
            key: {
              "client_id" => client_id 
            }, 
            table_name: ENV['KANBANIZE_CLIENTS_TABLE_NAME'],
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
