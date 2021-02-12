require 'aws-sdk-dynamodb'
require 'pokebot/topic/sns'

module Pokebot
  module Service
    module User
      module Favourite 
        extend self

        @@dynamo_resource = nil 

        def call(event)
          if favourite(event.user_id, event.recipe_id) 
            event.favourites = favourites(event.user_id) # only update if favourite is new
            Pokebot::Topic::Sns.broadcast(topic: :user, event: Pokebot::Lambda::Event::FAVOURITE_CREATED, state: event.state)
          end
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
            table_name: ENV['FAVOURITES_TABLE_NAME'],
            return_values: 'ALL_OLD'
          })[:attributes] == nil # return true if no attributes as ALL_OLD => nil indicates a new value
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

