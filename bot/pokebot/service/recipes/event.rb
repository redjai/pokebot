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

        def type
          @event['event']
        end

        def user_id
          @event['state']['slack']['interaction']['user']['id']
        end
        
        def recipe_id
          @event['state']['interaction']['favourite']
        end
      end
    end
  end
end

