require_relative 'event'

module Pokebot
  module Service
    module Intent
      module Controller
        extend self

        def call(pokebot_event)
          event = Pokebot::Service::Intent::Event.new(pokebot_event)

          case event.slack_text
          when /like/
            # do nothing now
          when /dislike/
           # do nothing for now
          else
            require_relative 'recipe_search'
            Pokebot::Service::Intent::RecipeSearch.call(event)
          end  
        end
      end
    end
  end
end
