module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module ComplexSearch
          extend self

          def search(text)
            response(search_uri(text))
          end
          
          def search_uri(text)
            params = { :query => text }
            uri('https://api.spoonacular.com/recipes/complexSearch', params)
          end
          
          def ids_from_complex_search(complex_search_result)
            complex_search_result['results'].collect do |result|
              result['id']
            end
          end

        end
      end
    end
  end
end
