module Pokebot
  module Service
    module User
      class Event

        def initialize(pokebot_event)
          @event = pokebot_event
        end

        def recipe_id
          @event['state']['interaction']['favourite']
        end

        def user_id
          @event['state']['slack']['interaction']['user']['id']
        end

        def favourite?
          @event['state']['interaction']['favourite']
        end

        def favourites=(favourites)
          @event['state']['user'] = { 'favourites' => favourites }
        end

        def state
          @event['state']
        end

      end 
    end
  end
end
