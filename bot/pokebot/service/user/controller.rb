require_relative 'event'

module Pokebot
  module Service
    module User 
      module Controller
        extend self

        def call(bot_event)
          case bot_event.name
          when Pokebot::Lambda::Event::FAVOURITE_NEW
            favourite(bot_event)
          end
        end


        def favourite(bot_event)
          require_relative 'favourite'
          Pokebot::Service::User::Favourite.call(bot_event)
        end
      end
    end
  end
end
