module Pokebot
  module Service
    module Recipe
      class Event

        ORIGIN_SLACK_EVENT = 'origin-slack-event'
        ORIGIN_SLACK_INTERACTION = 'origin-slack-interaction'

        def initialize(recipe_event)
          @event = recipe_event
        end

        def origin
          if @event['state']['slack']['event']
            ORIGIN_SLACK_EVENT
          elsif @event['state']['slack']['interaction']
            ORIGIN_SLACK_INTERACTION
          else
            raise 'unexpected origin'
          end
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
          case origin
          when ORIGIN_SLACK_EVENT
            @event['state']['slack']['event']['user']
          when ORIGIN_SLACK_INTERACTION
            @event['state']['slack']['interaction']['user']['id']
          end
        end
        
        def recipe_id
          @event['state']['interaction']['favourite']
        end
      end
    end
  end
end

