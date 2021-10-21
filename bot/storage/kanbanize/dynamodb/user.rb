require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
      module User
        extend self

        @@dynamo_resource = nil 
        
        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
        end

        def user_id(team_id:, slack_id:)
          "#{team_id}-#{slack_id}"
        end

        def destroy(team_id:, slack_id:)
          begin 
            dynamo_resource.client.delete_item(
              {
                key: {
                  "user_id" => user_id(team_id: team_id, slack_id: slack_id)
                },  
                table_name: ENV['USERS_TABLE_NAME']
              }
            ) 
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
            # our conditional failed because we have a duplicate favourite
            # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
          end
        end
  
        def read(team_id:, slack_id:)
          dynamo_resource.client.query({
            expression_attribute_values: {
              ":user_id" => user_id(team_id: team_id, slack_id: slack_id)
            },
            key_condition_expression: "user_id = :user_id", 
            table_name: ENV['USERS_TABLE_NAME'],
            select: "ALL_ATTRIBUTES"
          }).items.first || nil_user 
        end

        def create(team_id:, slack_id:)
          dynamo_resource.client.put_item(
            {
              item: {
                "user_id" => user_id(team_id: team_id, slack_id: slack_id)
              },
              table_name: ENV['USERS_TABLE_NAME']
            }
          ) 
        end

        def set_kanbanize_username(team_id:, slack_id:, kanbanize_username:)
          dynamo_resource.client.update_item(
            {
              key: {
                "user_id" => user_id(team_id: team_id, slack_id: slack_id) 
              },  
              update_expression: 'SET #kanbanize_username = :kanbanize_username',
              expression_attribute_names: {
                '#kanbanize_username': 'kanbanize_username'
              },
              expression_attribute_values: {
                ':kanbanize_username': kanbanize_username
              },
              table_name: ENV['USERS_TABLE_NAME'],
            }
          ) 
        end

        def update(team_id:, slack_id:, handle:, kanbanize_username:, email:)
          begin 
            dynamo_resource.client.update_item(
              {
                key: {
                  "user_id" => user_id(team_id: team_id, slack_id: slack_id) 
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

        def options
          { region: ENV['REGION'] }.tap do |opts|
            opts[:endpoint] = ENV['DYNAMO_ENDPOINT'] if ENV['DYNAMO_ENDPOINT'] 
            opts[:ssl_verify_peer] = (ENV['VERIFY_SSL_PEER'].to_s.downcase != 'false')
          end
        end

      end 
    end
  end
end
