require 'topic/sns'
require_relative 'complex_search'
require_relative 'favourites'
require_relative 'information_bulk_search'

module Service
  module Recipe
    module Spoonacular 
      module FreeTextSearch
        extend self

        def call(bot_event)
          Topic::Sns.broadcast(
            topic: :responses, 
            source: :recipes,
            name: Bot::Event::RECIPES_FOUND,  
            version: 1.0,
            event: bot_event,
            data: { 
              recipes: recipes(   
                                  text: bot_event.data['query'],
                               user_id: bot_event.data['user']['slack_id'],
                                offset: bot_event.data['offset'].to_i
                              ),
                    user: bot_event.data['user']
                  }
          )
        end
        
        def recipes(text:, user_id:, offset:)
          complex_search = Service::Recipe::Spoonacular::ComplexSearch.search_free_text(text)
          {
            'complex_search' => complex_search,
            'information_bulk' => information_bulk_result(complex_search),
            'favourite_recipe_ids' => Service::Recipe::Spoonacular::Favourites.recipe_ids(user_id),
            'query' => Service::Recipe::Spoonacular::ComplexSearch.params(text, offset)
          }
        end

        def information_bulk_result(search_result)
          if search_result['totalResults'] > 0
             search_result_ids = Service::Recipe::Spoonacular::ComplexSearch.ids_from_complex_search_result(search_result)
             Service::Recipe::Spoonacular::InformationBulkSearch.search_by_ids(search_result_ids)
          else
             []
          end
        end
      end
    end
  end
end
