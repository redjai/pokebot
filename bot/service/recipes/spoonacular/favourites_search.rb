require 'topic/sns'
require_relative 'information_bulk_search'
require_relative 'favourites'

module Service
  module Recipe
    module Spoonacular 
      module FavouritesSearch
        extend self
        
        def call(bot_event)
          Topic::Sns.broadcast(
            topic: :responses, 
            source: :recipes_favourites_search,
            name: Bot::Event::RECIPES_FOUND,  
            version: 1.0,
            event: bot_event,
            data: { 
                    recipes: recipes(bot_event.data['user']['slack_id']),
                    user: bot_event.data['user']
                  }
          )
        end
        
        def recipes(user_id)
          recipe_ids = Service::Recipe::Spoonacular::Favourites.recipe_ids(user_id)
          bulk_result = if recipe_ids.count > 0
                          Service::Recipe::Spoonacular::InformationBulkSearch.search_by_ids(recipe_ids)
                        else
                          []
                        end
          {
            'information_bulk' => bulk_result,
            'favourite_recipe_ids' => recipe_ids,
          }
        end
      end
    end
  end
end
