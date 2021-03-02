require_relative 'base'

module Service
  module Recipe
    module Spoonacular 
      module ComplexSearch
        extend self
        extend Service::Recipe::Spoonacular::Base

        def search_free_text(text, offset=0)
          response(search_uri(text, offset))
        end

        def params(text, offset)
         { :query => text, :offset => offset }
        end
        
        def search_uri(text, offset)
          uri('https://api.spoonacular.com/recipes/complexSearch', params(text, offset))
        end
        
        def ids_from_complex_search_result(complex_search_result)
          complex_search_result['results'].collect do |result|
            result['id']
          end
        end

      end
    end
  end
end
