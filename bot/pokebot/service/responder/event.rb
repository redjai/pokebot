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
          @event['state']['recipes']['spoonacular']['information_bulk']
        end

      end
    end
  end
end
