require 'aws-sdk-dynamodb'
require 'topic/sns'
require_relative '../storage'

module Service
  module User
    module Account 
      module Update 
      extend self
        def call(bot_request)
          Service::User::Storage.update_account(
                                                  slack_id: bot_request.context.slack_id,
                                                  handle: bot_request.data['handle'],
                                                  kanbanize_username: bot_request.data['kanbanize_username'],
                                                  email: bot_request.data['email']
                                               ).tap do |user|
                                                 bot_request.events << ::Request::Events::Users.account_updated(source: :user, 
                                                                                                    handle: user.attributes['handle'], 
                                                                                                     email: user.attributes['email'],
                                                                                        kanbanize_username: user.attributes['kanbanize_username'])
            Topic::Sns.broadcast(topic: :users, request: bot_request)
          end
        end
      end
    end
  end
end

