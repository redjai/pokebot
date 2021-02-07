require_relative 'event'

module Pokebot
  module Service
    module User 
      module Controller
        extend self

        def call(pokebot_event)
          event = Pokebot::Service::User::Event.new(pokebot_event)
          favourite(event) if event.favourite? 
        end


        def favourite(event)
          require_relative 'favourite'
          Pokebot::Service::User::Favourite.call(event)
        end
      end
    end
  end
end
