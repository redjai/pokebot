require 'pokebot/topic/sns'
require 'aws-sdk-dynamodb'
require_relative 'complex_search'
require_relative 'information_bulk_search'
require_relative 'base'

module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module FreeTextSearch
          extend self
          extend Pokebot::Service::Recipe::Spoonacular::InformationBulkSearch
          extend Pokebot::Service::Recipe::Spoonacular::Base

          @@dynamo_resource = nil 
          
          def dynamo_resource
            @@dynamo_resource = Aws::DynamoDB::Resource.new(region: ENV['REGION'])
          end

          def call(event)
            event.recipes = recipes(ids(event.user_id))
            Pokebot::Topic::Sns.broadcast(
              topic: :responses, 
              event: Pokebot::Lambda::Event::RECIPES_FOUND,  
              state: event.state
            )
          end

          def ids(user_id)
            puts favourites(user_id)
            favourites(user_id).collect{ |item| item["recipe_id"]  }
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
          
          def recipes(ids)
            bulk_result = if ids.count > 0
                            information_bulk(ids)
                          else
                            []
                          end
            {
              'information_bulk' => bulk_result
            }
          end
        end
      end
    end
  end
end
