require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
      module UserFavourites 
      extend self

      @@dynamo_resource = nil 
      
        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
        end

        def user_id(team_id:, slack_id:)
          "#{team_id}-#{slack_id}"
        end

        def remove_favourite(team_id:, slack_id:, recipe_id:)
          begin 
            dynamo_resource.client.update_item(
              {
                key: {
                  "user_id" => user_id(team_id: team_id, slack_id: slack_id) 
                },  
                update_expression: 'DELETE #favourites :recipe_id',
                expression_attribute_names: {
                  '#favourites': 'favourites'
                },
                expression_attribute_values: {
                  ':recipe_id': Set.new([recipe_id.to_s])
                },
                table_name: ENV['USERS_TABLE_NAME'],
                return_values: 'UPDATED_NEW'
              }
            ) 
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
            # our conditional failed because we have a duplicate favourite
            # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
          end
        end

        def add_favourite(team_id:, slack_id:, recipe_id:)
          begin 
            dynamo_resource.client.update_item(
              {
                key: {
                  "user_id" => user_id(team_id: team_id, slack_id: slack_id) 
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
                table_name: ENV['USERS_TABLE_NAME'],
                return_values: 'UPDATED_NEW'
              }
            ) 
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
            # our conditional failed because we have a duplicate favourite
            # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
          end
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
end
