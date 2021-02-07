module Pokebot
  module Service
    module Interaction
      class Event

        def initialize(interaction_event)
          @event = interaction_event
        end

        def actions
          @event['state']['slack']['interaction']['actions'].collect{ |action| Action.new(action) }
        end

        def favourite=(id)
          @event['state']['interaction'] = { 'favourite' => id }
        end

        def state
          @event['state']
        end

      end

      class Action

        REGEX = /^Favourite-(.+)/ 

        def initialize(action)
          @action = action
        end

        def favourite?
          REGEX.match?(@action['value']) 
        end

        def id
          REGEX.match(@action['value'])[1]
        end

      end
    end
  end
end
