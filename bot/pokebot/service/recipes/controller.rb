require_relative 'event'

module Pokebot
  module Service
    module Recipe
      module Controller
        def self.call(pokebot_event)
          require_relative 'spoonacular'
          event = Pokebot::Service::Recipe::Event.new(pokebot_event)
          Pokebot::Service::Spoonacular.call(event)
        end
      end
    end
  end
end  
