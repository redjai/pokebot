require 'pokebot/topic/sns'
require_relative 'complex_search'
require_relative 'favourites'
require_relative 'information_bulk_search'

module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module FreeTextSearch
          extend self

          def call(bot_event)
            Pokebot::Topic::Sns.broadcast(
              topic: :responses, 
              source: :recipes,
              name: Bot::Event::RECIPES_FOUND,  
              version: 1.0,
              event: bot_event,
              data: { 
                      recipes: recipes(bot_event.data['query'],
                                       bot_event.data['user']['slack_id'],
                                       bot_event.data),
                      user: bot_event.data['user']
                    }
            )
          end
          
          def recipes(text, user_id, offset=0)
            search_result = Pokebot::Service::Recipe::Spoonacular::ComplexSearch.search_free_text(text)
            bulk_result = if search_result['totalResults'] > 0
                            search_result_ids = Pokebot::Service::Recipe::Spoonacular::ComplexSearch.ids_from_complex_search_result(search_result)
                            Pokebot::Service::Recipe::Spoonacular::InformationBulkSearch.search_by_ids(search_result_ids)
                          else
                            []
                          end
            recipe_ids = Pokebot::Service::Recipe::Spoonacular::Favourites.recipe_ids(user_id)
            {
              'search' => search_result,
              'information_bulk' => bulk_result,
              'favourite_recipe_ids' => recipe_ids,
              'query' => Pokebot::Service::Recipe::Spoonacular::ComplexSearch.params(text, offset)
            }
          end
        end
      end
    end
  end
end
