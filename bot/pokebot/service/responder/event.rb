module Pokebot
  module Service
    module Responder
      class Event

        def initialize(pokebot_event)
          @event = pokebot_event
        end

        def channel
          @event['state']['slack']['event']['channel']
        end

        def spoonacular_recipes
          @event['state'].fetch('recipes',{}).fetch('spoonacular',{})['information_bulk']
        end

        def spoonacular_recipe_response?
          spoonacular_recipes
        end

        def slack_message?
          @event['state']['slack']
        end

        def search_response?
          @event['state']['intent'] == 'search' 
        end

        def slack_text
          @event['state']['slack']['event']['text'].gsub(/<[^>]+>/,"").strip
        end
      end
    end
  end
end
