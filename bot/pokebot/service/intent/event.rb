module Pokebot
  module Service
    module Intent
      class Event

        def initialize(pokebot_event)
          @event = pokebot_event
        end
        
        def slack_text
          @event['state']['slack']['event']['text'].gsub(/<[^>]+>/,"").strip
        end

        def state
          @event['state']
        end

      end
    end
  end
end
