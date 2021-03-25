require 'topic/sns'
require_relative 'api/information_bulk_search'
require_relative '../user'
require 'topic/topic'

module Service
  module Recipe
    module Spoonacular 
      module FavouritesSearch
        extend self
        
        def call(bot_request)
          recipe_ids = Service::Recipe::User.recipe_ids(bot_request.slack_user['slack_id'])
          bot_request.current = Topic::Recipes.favourites_found(        source: :recipes, 
                                                                               recipes: information_bulk(recipe_ids),
                                                                  favourite_recipe_ids: recipe_ids) 
          Topic::Sns.broadcast(
                                topic: :recipes, 
                                event: bot_request
                              )
        end
        
        def information_bulk(recipe_ids)
          if recipe_ids.count > 0
            Service::Recipe::Spoonacular::InformationBulkSearch.search_by_ids(recipe_ids)
          else
            []
          end
        end
      end
    end
  end
end

