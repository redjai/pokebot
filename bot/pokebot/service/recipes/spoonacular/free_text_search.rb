require 'pokebot/topic/sns'
require_relative 'complex_search'
require_relative 'favourites'
require_relative 'information_bulk_search'
require_relative 'base'

module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module FreeTextSearch
          extend self
          extend Pokebot::Service::Recipe::Spoonacular::ComplexSearch
          extend Pokebot::Service::Recipe::Spoonacular::InformationBulkSearch
          extend Pokebot::Service::Recipe::Spoonacular::Favourites
          extend Pokebot::Service::Recipe::Spoonacular::Base

          def call(event)
            event.recipes = recipes(event.slack_text, event.user_id)
            Pokebot::Topic::Sns.broadcast(
              topic: :responses, 
              event: Pokebot::Lambda::Event::RECIPES_FOUND,  
              state: event.state
            )
          end
          
          def recipes(text, user_id)
            search_result = search(text)
            bulk_result = if search_result['totalResults'] > 0
                            information_bulk(ids_from_complex_search(search_result))
                          else
                            []
                          end
            recipe_ids = favourites(user_id)
            {
              'search' => search_result,
              'information_bulk' => bulk_result,
              'favourite_recipe_ids' => recipe_ids
            }
          end
        end
      end
    end
  end
end
