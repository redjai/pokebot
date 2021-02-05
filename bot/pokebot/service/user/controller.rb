module Pokebot
  module Service
    module User 
      module Controller
        extend self

        def call(pokebot_event)
          favourite(pokebot_event) if favourite?(pokebot_event) 
        end

        def favourite?(pokebot_event)
          pokebot_event['state']['interaction']['favourite']
        end

        def favourite(pokebot_event)
          require_relative 'favourite'
          Pokebot::Service::User::Favourite.call(pokebot_event)
        end
      end
    end
  end
end
