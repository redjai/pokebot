require_relative '../event'
require_relative 'base'
require_relative 'base'
module Topic 
  module Events
    module Recipes
      extend self
      extend Topic::Events::Base

      def search_requested(source:, query:, offset: 0)
        data = {
          'query' => query,
          'offset' => offset 
        }
        Topic::Event.new(source: source, name: RECIPE_SEARCH_REQUESTED, version: 1.0, data: data)      
      end

      def found(source:, complex_search:, information_bulk:, favourite_recipe_ids:, query:)
        data = {
          'complex_search' => complex_search,
          'information_bulk' => information_bulk,
          'favourite_recipe_ids' => favourite_recipe_ids,
          'query' => query
        }
        Topic::Event.new(source: source, name: RECIPES_FOUND, version: 1.0, data: data)      
      end

      def favourites_requested(source:, offset: 0)
        data = { offset: offset }
        Topic::Event.new(source: source, name: FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data)      
      end
      
      def favourites_found(source:, information_bulk:, favourite_recipe_ids:)
        data = {
          'information_bulk' => information_bulk,
          'favourite_recipe_ids' => favourite_recipe_ids,
        }
        Topic::Event.new(source: source, name: RECIPES_FOUND, version: 1.0, data: data)      
      end

    end

  end
end
