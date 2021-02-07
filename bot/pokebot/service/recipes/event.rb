module Pokebot
  module Service
    module Recipe
      class Event

        def initialize(recipe_event)
          @event = recipe_event
        end

        def slack_text
          @event['state']['slack']['event']['text'].gsub(/<[^>]+>/,"").strip
        end

        def recipes=(recipes)
          @event['state']['recipes'] = { 'spoonacular' => recipes }
        end

        def state
          @event['state']
        end

      end
    end
  end
end

