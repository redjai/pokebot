require 'aws-sdk-dynamodb'
require 'pokebot/topic/sns'

module Pokebot
  module Service
    module User
      module Favourite 
        extend self

        @@dynamo_resource = nil 

        def call(event)
          updates = favourite(event.user_id, event.recipe_id) 
          if updates
            event.favourites = updates['attributes']['favourites'].to_a #favourites is a Set
            Pokebot::Topic::Sns.broadcast(topic: :user, event: Pokebot::Lambda::Event::USER_FAVOURITES_UPDATED, state: event.state)
          end
        end

        def dynamo_resource
          @@dynamo_resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'])
        end

        def favourite(user_id, recipe_id)
          begin 
            dynamo_resource.client.update_item(update_query(user_id, recipe_id))
          rescue Aws::DynamoDB::Errors::ConditionalCheckFailedException
            # our conditional failed because we have a duplicate favourite
            # attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)
          end
        end

        def update_query(user_id, recipe_id)
          {
            key: {
              "user_id" => user_id 
            },  
            update_expression: 'ADD #favourites :empty_set',
            expression_attribute_names: {
              '#favourites': 'favourites'
            },
            condition_expression: 'attribute_not_exists(#favourites) OR not contains(#favourites, :recipe_id)',
            expression_attribute_values: {
              ':empty_set': Set.new([recipe_id]),
              ':recipe_id': recipe_id
            },
            table_name: ENV['FAVOURITES_TABLE_NAME'],
            return_values: 'UPDATED_NEW'
          }
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

