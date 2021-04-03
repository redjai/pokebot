require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative '../storage'

module Service
  module User
    module Account 
      module Requested
      extend self

        def call(bot_request)
          Service::User::Storage.read(bot_request.context.slack_id).tap do |user|
            bot_request.current = Topic::Users.account_found(source: :user, user: user)
            Topic::Sns.broadcast(topic: :users, event: bot_request)
          end
        end
      end
    end
  end
end

