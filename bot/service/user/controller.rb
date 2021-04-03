require 'topic/topic'

module Service
  module User 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when Topic::Users::FAVOURITE_NEW
          require_relative 'favourite/add'
          Service::User::Favourite::Add.call(bot_request)
        when Topic::Users::FAVOURITE_DESTROY
          require_relative 'favourite/remove'
          Service::User::Favourite::Remove.call(bot_request)
        when Topic::Users::ACCOUNT_REQUESTED
          require_relative 'account/requested'
          Service::User::Account::Requested.call(bot_request)
        when Topic::Users::ACCOUNT_EDIT
          require_relative 'account/edit'
          Service::User::Account::Edit.call(bot_request)
        end
      end
    end
  end
end
