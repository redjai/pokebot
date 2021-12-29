require 'aws-sdk-dynamodb'

module Storage
  module Kanbanize
    module DynamoDB
      module RecipeFavourites
        extend self

        @@dynamo_resource = nil 

        def user_id(team_id:, slack_id:)
          "#{team_id}-#{slack_id}"
        end
        
        def recipe_ids(team_id:, slack_id:)
          user = read(team_id: team_id, slack_id: slack_id)
          user.nil? ? [] : user['favourites'].collect{|id| id.to_s }
        end

        def read(team_id:, slack_id:)
          dynamo_resource.client.query({
            expression_attribute_values: {
              ":u1" => user_id(team_id: team_id, slack_id: slack_id)
            },
            key_condition_expression: "user_id = :u1", 
            table_name: ENV['FAVOURITES_TABLE_NAME'],
            select: "ALL_ATTRIBUTES"
          }).items.first
        end
        
        def upsert(team_id:, slack_id:, favourites:)
          dynamo_resource.client.update_item({
            key: {
              "user_id" => user_id(team_id: team_id, slack_id: slack_id), 
            },  
            update_expression: 'set #favourites = :favourites',
            expression_attribute_names: {
              '#favourites': 'favourites'
            },
            expression_attribute_values: {
              ':favourites': favourites
            },
            table_name: ENV['FAVOURITES_TABLE_NAME'] 
          })
        end
        
        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(options)
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