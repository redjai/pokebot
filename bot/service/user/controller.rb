require 'request/events/users'

module Service
  module User 
    module Controller
      extend self

      def call(bot_request)
        case bot_request.name
        when ::Request::Events::Users::FAVOURITE_NEW
          require_relative 'favourite/add'
          Service::User::Favourite::Add.call(bot_request)
        when ::Request::Events::Users::FAVOURITE_DESTROY
          require_relative 'favourite/remove'
          Service::User::Favourite::Remove.call(bot_request)
        when ::Request::Events::Users::ACCOUNT_SHOW_REQUESTED
          require_relative 'account/read'
          Service::User::Account::Read.call(bot_request)
        when ::Request::Events::Users::ACCOUNT_EDIT_REQUESTED
          require_relative 'account/read'
          Service::User::Account::Read.call(bot_request)
        when ::Request::Events::Users::ACCOUNT_UPDATE_REQUESTED
          require_relative 'account/update'
          Service::User::Account::Update.call(bot_request)
        end
      end
    end
  end
end
