require 'topic/topic'

module Service
  module User 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when Topic::Users::FAVOURITE_NEW
          require_relative 'favourite'
          Service::User::Favourite.call(bot_request)
        when Topic::Users::FAVOURITE_DESTROY
          require_relative 'unfavourite'
          Service::User::Unfavourite.call(bot_request)
        when Topic::Users::ACCOUNT_EDIT
          require_relative 'account'
          Service::User::Account.call(bot_request)
        end
      end
    end
  end
end
