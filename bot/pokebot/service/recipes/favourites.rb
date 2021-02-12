require 'aws-sdk-dynamodb'

module Pokebot
  module Service
    module Recipe 
      module Favourite 
        extend self

        @@dynamo_resource = nil 

        def call(event)
          favourite(event.user_id, event.recipe_id)
        end

        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'])
        end

        def favourite(user_id, recipe_id)
          dynamo_resource.client.update_item({
            key: {
              "user_id" => user_id, 
              "recipe_id" => recipe_id.to_i, 
            },  
            table_name: ENV['FAVOURITES_TABLE_NAME'] 
          })
        end

        def favourites(user_id)
          dynamo_resource.client.query({
            expression_attribute_values: {
              ":u1" => user_id
            },
            key_condition_expression: "user_id = :u1", 
            table_name: ENV['FAVOURITES_TABLE_NAME'],
            select: "ALL_ATTRIBUTES"
          }).items
        end
      end
    end
  end
end
