require 'topic/topic'

module Service
  module User 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when Topic::Users::FAVOURITE_NEW
          favourite(bot_request)
        when Topic::Users::FAVOURITE_DESTROY
          unfavourite(bot_request)
        end
      end


      def favourite(bot_request)
        require_relative 'favourite'
        Service::User::Favourite.call(bot_request)
      end
      
      def unfavourite(bot_request)
        require_relative 'unfavourite'
        Service::User::Unfavourite.call(bot_request)
      end
    end
  end
end
