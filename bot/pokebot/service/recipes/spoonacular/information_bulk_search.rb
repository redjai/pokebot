require_relative 'base'

module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module InformationBulkSearch
          extend self
          extend Pokebot::Service::Recipe::Spoonacular::Base

          def search_by_ids(ids)
            response(bulk_recipe_uri(ids))
          end
          
          def bulk_recipe_uri(ids)
            uri('https://api.spoonacular.com/recipes/informationBulk', ids_query(ids))
          end

          def ids_query(ids)
            { :ids => ids.join(",") }
          end
        end
      end
    end
  end
end
