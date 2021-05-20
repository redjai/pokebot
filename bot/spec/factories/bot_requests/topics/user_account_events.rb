require 'topic/event'
require 'topic/topic'

module TopicHelper
  extend Topic::Base
end

FactoryBot.define do

  factory :user_account_show_requested, class: Topic::Event do

    source { :test_source }

    initialize_with{ Topic::Users.account_show_requested(source: source) }

  end

  factory :user_account_read, class: Topic::Event do

    source { :test_source }

    transient do
      handle { 'test-handle' }
      kanbanize_username { 'test-kanbanize-username' }
      user { {'user_id' => user_id, 'handle' => handle, 'kanbanize_username' => kanbanize_username }  }
      user_id { 'user-id-123' }
    end

    initialize_with{ Topic::Users.account_read(source: source, user: user) }

  end

  factory :user_account_edit_requested, class: Topic::Event do

    source { :test_source }

    initialize_with{ Topic::Users.account_edit_requested(source: source) }

  end

  factory :user_account_update_requested, class: Topic::Event do

    source { :test_source }
    name { Faker::Name.name  }
    email { Faker::Internet.email }
    kanbanize_username { Faker::Internet.username }

    initialize_with{ Topic::Users.account_update_requested(source: source, handle: name, email: email, kanbanize_username: kanbanize_username) }

  end

  factory :slack_command_user_account_show_requested_event, class: Topic::Event do
    initialize_with{ Topic::Slack.command_event(slack_command_account_event) } 
  end

end
