require_relative '../event'
require_relative 'base'
require 'topic/topic'

module Topic 
  module Events
    module Recipes
      extend self
      extend Topic::Events::Base
        
        def search_requested(source:, query:, offset: 0, per_page: 10)
          data = {
          'query' => query,
          'page' => { 'offset' => offset, 'per_page' => per_page },
        }
        Topic::Event.new(source: source, name: Topic::Recipes::SEARCH_REQUESTED, version: 1.0, data: data)      
      end

      def found(source:, recipes:, favourite_recipe_ids:, query:, offset:, per_page:, total_results:)
        data = {
          'recipes' => recipes,
          'favourite_recipe_ids' => favourite_recipe_ids,
          'query' => query,
          'page' => { 'offset' => offset, 'per_page' => per_page, 'total_results' => total_results }
        }
        Topic::Event.new(source: source, name: Topic::Recipes::FOUND, version: 1.0, data: data)      
      end

      def favourites_requested(source:, offset: 0)
        data = { offset: offset }
        Topic::Event.new(source: source, name: Topic::Recipes::FAVOURITES_SEARCH_REQUESTED, version: 1.0, data: data)      
      end
      
      def favourites_found(source:, recipes:, favourite_recipe_ids:)
        data = {
          'recipes' => recipes,
          'favourite_recipe_ids' => favourite_recipe_ids,
        }
        Topic::Event.new(source: source, name: Topic::Recipes::FOUND, version: 1.0, data: data)      
      end

    end

  end
end
