require 'pokebot/topic/sns'
module Pokebot
  module Service
    module Recipe
      def self.call(pokebot_event)
        require 'pokebot/service/spoonacular'
        Pokebot::Service::Spoonacular.call(pokebot_event)
        puts pokebot_event
        Pokebot::Topic::Sns.broadcast(
          topic: :responses, 
          event: Pokebot::Lambda::Event::POKEBOT_RESPONSE_RECEIVED,  
          state: pokebot_event['state']
        )
      end
    end
  end
end  
