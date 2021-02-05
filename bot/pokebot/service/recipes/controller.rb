module Pokebot
  module Service
    module Recipe
      module Controller
        def self.call(pokebot_event)
          require_relative 'spoonacular'
          Pokebot::Service::Spoonacular.call(pokebot_event)
        end
      end
    end
  end
end  
