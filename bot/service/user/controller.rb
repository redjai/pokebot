module Service
  module User 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when Topic::USER_FAVOURITE_NEW
          favourite(bot_request)
        end
      end


      def favourite(bot_request)
        require_relative 'favourite'
        Service::User::Favourite.call(bot_request)
      end
    end
  end
end
