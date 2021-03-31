require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative '../storage'

module Service
  module User
    module Account 
      module Edit
      extend self
        def call(bot_request)
          Service::User::Storage.update_account(bot_request.slack_user['slack_id'], bot_request.data['handle'], bot_request.data['kanbanize_username']).tap do |updated|
            bot_request.current = Topic::Users.account_update(source: :user, handle: updated[:attributes][:handle], kanbanize_username: updated[:attributes][:kanbanize_username])
            Topic::Sns.broadcast(topic: :users, event: bot_request)
          end
        end
      end
    end
  end
end

