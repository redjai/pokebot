require 'topic/sns'
require_relative 'spoonacular/api/information_bulk_search'
require_relative 'user'
require 'gerty/request/events/recipes'
require 'service/bounded_context'

module Service
  module Recipe
    module Spoonacular 
      module FavouritesSearch
        extend self

        def listen
          [ Gerty::Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED ]
        end

        def broadcast
          [ :recipes ]
        end

        Service::BoundedContext.register(self)
        
        def call(bot_request)
          recipe_ids = Service::Recipe::User.recipe_ids(bot_request.context.slack_id)
          bot_request.events << Gerty::Request::Events::Recipes.found(        source: :recipes, 
                                                            recipes: information_bulk(recipe_ids),
                                               favourite_recipe_ids: recipe_ids) 
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
