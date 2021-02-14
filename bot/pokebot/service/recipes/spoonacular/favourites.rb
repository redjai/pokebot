module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module Favourites

          def favourites(user_id)
            user = user(user_id)
            user.nil? ? [] : user['favourites']
          end

          def user(user_id)
            dynamo_resource.client.query({
              expression_attribute_values: {
                ":u1" => user_id
              },
              key_condition_expression: "user_id = :u1", 
              table_name: ENV['FAVOURITES_TABLE_NAME'],
              select: "ALL_ATTRIBUTES"
            }).items.first
          end
        end
      end
    end
  end
end
