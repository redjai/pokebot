require_relative 'base'

module Service
  module Recipe
    module Spoonacular 
      module ComplexSearch
        extend self
        extend Service::Recipe::Spoonacular::Base

        def search_free_text(text, offset=0, per_page=10)
          response(search_uri(text, offset, per_page))
        end

        def params(text, offset, per_page)
         { query: text, offset: offset, number: per_page }
        end
        
        def search_uri(text, offset, number)
          uri('https://api.spoonacular.com/recipes/complexSearch', params(text, offset, number))
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
