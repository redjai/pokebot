require 'aws-sdk-dynamodb'

module Pokebot
  module Service
    module Recipe 
      module Favourite 
        extend self

        @@dynamo_resource = nil 

        def call(event)
          favourite(event.user_id, event.favourites)
        end

        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'])
        end

        # we don't have to worry about duplicates assume the user service gatekeeps that for us
        def favourite(user_id, favourites)
          dynamo_resource.client.update_item({
            key: {
              "user_id" => user_id, 
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
