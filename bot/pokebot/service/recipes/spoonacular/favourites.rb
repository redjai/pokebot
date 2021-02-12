module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module Favourites

          def favourite_ids(user_id)
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
        end
      end
    end
  end
end
