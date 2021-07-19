require 'request/event'
require 'request/events/slack'
require 'request/events/users'

module TopicHelper
  extend Request::Base
end

FactoryBot.define do

  factory :user_account_show_requested, class: ::Request::Event do

    source { :test_source }

    initialize_with{ ::Request::Events::Users.account_show_requested(source: source) }

  end

  factory :user_account_read, class: ::Request::Event do

    source { :test_source }

    transient do
      handle { 'test-handle' }
      kanbanize_username { 'test-kanbanize-username' }
      user { {'user_id' => user_id, 'handle' => handle, 'kanbanize_username' => kanbanize_username }  }
      user_id { 'user-id-123' }
    end

    initialize_with{ ::Request::Events::Users.account_read(source: source, user: user) }

  end

  factory :user_account_edit_requested, class: ::Request::Event do

    source { :test_source }

    initialize_with{ ::Request::Events::Users.account_edit_requested(source: source) }

  end

  factory :user_account_update_requested, class: ::Request::Event do

    source { :test_source }
    name { Faker::Name.name  }
    email { Faker::Internet.email }
    kanbanize_username { Faker::Internet.username }

    initialize_with{ ::Request::Events::Users.account_update_requested(source: source, handle: name, email: email, kanbanize_username: kanbanize_username) }

  end

  factory :slack_command_user_account_show_requested_event, class: ::Request::Event do
    initialize_with{ ::Request::Events::Slack.command_event(slack_command_account_event) } 
  end

end
