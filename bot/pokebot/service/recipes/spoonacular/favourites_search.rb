require 'pokebot/topic/sns'
require_relative 'complex_search'
require_relative 'information_bulk_search'
require_relative 'favourites'
require_relative 'base'

module Pokebot
  module Service
    module Recipe
      module Spoonacular 
        module FavouritesSearch
          extend self
          extend Pokebot::Service::Recipe::Spoonacular::InformationBulkSearch
          extend Pokebot::Service::Recipe::Spoonacular::Favourites
          extend Pokebot::Service::Recipe::Spoonacular::Base

          def call(event)
            event.recipes = recipes(favourite_ids(event.user_id))
            Pokebot::Topic::Sns.broadcast(
              topic: :responses, 
              event: Pokebot::Lambda::Event::RECIPES_FOUND,  
              state: event.state
            )
          end
          
          def recipes(ids)
            bulk_result = if ids.count > 0
                            information_bulk(ids)
                          else
                            []
                          end
            {
              'information_bulk' => bulk_result
            }
          end
        end
      end
    end
  end
end
