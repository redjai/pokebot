require 'pokebot/topic/sns'
require_relative 'complex_search'
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
          extend Pokebot::Service::Recipe::Spoonacular::Base

          def call(event)
            event.recipes = recipes(event.slack_text)
            Pokebot::Topic::Sns.broadcast(
              topic: :responses, 
              event: Pokebot::Lambda::Event::RECIPES_FOUND,  
              state: event.state
            )
          end
          
          def recipes(text)
            search_result = search(text)
            bulk_result = if search_result['totalResults'] > 0
                            information_bulk(ids(search_result))
                          else
                            []
                          end
            {
              'search' => search_result,
              'information_bulk' => bulk_result
            }
          end
        end
      end
    end
  end
end
