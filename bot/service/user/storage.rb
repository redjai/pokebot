require 'aws-sdk-dynamodb'
require 'topic/sns'

module Service
  module User
    module Storage 
      extend self

      @@dynamo_resource = nil 
      
      def dynamo_resource
        @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
      end

      def remove_favourite(slack_id, recipe_id)
        begin 
          dynamo_resource.client.update_item(
            {
              key: {
                "user_id" => slack_id 
              },  
              update_expression: 'DELETE #favourites :recipe_id',
              expression_attribute_names: {
                '#favourites': 'favourites'
              },
              expression_attribute_values: {
                ':recipe_id': Set.new([recipe_id.to_s])
              },
              table_name: ENV['FAVOURITES_TABLE_NAME'],
              return_values: 'UPDATED_NEW'
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def add_favourite(slack_id, recipe_id)
        begin 
          dynamo_resource.client.update_item(
            {
              key: {
                "user_id" => slack_id 
              },  
              update_expression: 'ADD #favourites :empty_set',
              expression_attribute_names: {
                '#favourites': 'favourites'
              },
              condition_expression: 'attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)',
              expression_attribute_values: {
                ':empty_set': Set.new([recipe_id.to_s]),
                ':recipe_id': recipe_id
              },
              table_name: ENV['FAVOURITES_TABLE_NAME'],
              return_values: 'UPDATED_NEW'
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def update_account(slack_id:, handle:, kanbanize_username:, email:)
        begin 
          dynamo_resource.client.update_item(
            {
              key: {
                "user_id" => slack_id 
              },  
              update_expression: 'SET #handle = :handle, #kanbanize_username = :kanbanize_username, #email = :email',
              expression_attribute_names: {
                '#handle': 'handle',
                '#kanbanize_username': 'kanbanize_username',
                '#email': 'email'
              },
              expression_attribute_values: {
                ':handle': handle,
                ':kanbanize_username': kanbanize_username,
                ':email': email 
              },
              table_name: ENV['FAVOURITES_TABLE_NAME'],
              return_values: 'UPDATED_NEW'
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def destroy(slack_id)
        begin 
          dynamo_resource.client.delete_item(
            {
              key: {
                "user_id" => slack_id 
              },  
              table_name: ENV['FAVOURITES_TABLE_NAME']
            }
          ) 
        rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
          # our conditional failed because we have a duplicate favourite
          # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
        end
      end

      def read(slack_id)
        dynamo_resource.client.query({
          expression_attribute_values: {
            ":u1" => slack_id
          },
          key_condition_expression: "user_id = :u1", 
          table_name: ENV['FAVOURITES_TABLE_NAME'],
          select: "ALL_ATTRIBUTES"
        }).items.first || nil_user 
      end

      def nil_user
        { "handle" => nil, "kanbanize_username" => nil, "favourites" => [] }
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

