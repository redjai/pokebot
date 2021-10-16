require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Recipes
        extend self
        extend Gerty::Request::Base
          
        SEARCH_REQUESTED = 'recipes-search-requested'
        FAVOURITES_SEARCH_REQUESTED = 'favourites-search-requested'
        FOUND = 'recipes-found'
        
        def search_requested(source:, query:, offset: 0, per_page: 10)
            data = {
            'query' => query,
            'page' => { 'offset' => offset, 'per_page' => per_page },
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Recipes::SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
        end

        def found(source:, recipes:, favourite_recipe_ids:, query: nil, offset: nil, per_page: nil, total_results: nil)
          data = {
            'recipes' => recipes,
            'favourite_recipe_ids' => favourite_recipe_ids,
          }
          if query
            data['query'] = query
            data['page'] = { 'offset' => offset, 'per_page' => per_page, 'total_results' => total_results }
          end
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Recipes::FOUND, version: 1.0, data: data)      
        end

        def favourites_requested(source:, offset: 0)
          data = { offset: offset }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data, intent: true)      
        end
          
      end
    end
  end
end