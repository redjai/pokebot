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
    handle { 'test handle' }
    kanbanize_username { 'test-kanbanze-username' }

    initialize_with{ Topic::Users.account_update(source: source, handle: handle, kanbanize_username: kanbanize_username) }

  end

  factory :slack_command_account_requested_event, class: Topic::Event do
    initialize_with{ Topic::Slack.command_event(slack_command_account_event) } 
  end

  factory :slack_interaction_user_update_requested, class: Topic::Event do
    initialize_with{ Topic::Slack.interaction_event(user_update_requested_view_submission) } 
  end
end
