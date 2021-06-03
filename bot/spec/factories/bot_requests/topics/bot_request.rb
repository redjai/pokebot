require 'topic/event'
require 'topic/topic'

FactoryBot.define do

  sequence :slack_id do |n|
    "UTESTSLACKID#{n}"
  end
  
  sequence :channel do |n|
    "CTESTSLACKCHANNEL#{n}"
  end

  sequence :trigger_id do |n|
    "test-trigger-id-#{n}"
  end

  sequence :response_url do |n|
    "https://test-slack-response-url/#{n}"
  end


  factory :event_context, class: Topic::SlackContext do
    slack_id { generate :slack_id }
    channel { generate :channel }
    initialize_with{ Topic::SlackContext._from_slack_event(slack_id: slack_id, channel: channel) }
  end

  factory :command_context, class: Topic::SlackContext do
    slack_id { generate :slack_id }
    channel { generate :channel }
    response_url { generate :response_url }
    initialize_with{ Topic::SlackContext._from_slack_coommand(slack_id: slack_id, channel: channel, response_url: response_url) }
  end

  factory :block_actions_interaction_context, class: Topic::SlackContext do
    slack_id { generate :slack_id }
    channel { generate :channel }
    response_url { generate :response_url }
    trigger_id { generate :trigger_id }
    message_ts { Faker::Time.backward.to_i }

    initialize_with{ Topic::SlackContext._from_slack_block_actions_interaction(slack_id: slack_id, channel: channel, response_url: response_url, trigger_id: trigger_id, message_ts: message_ts) }
  end
  
  factory :view_submission_interaction_context, class: Topic::SlackContext do

    slack_id { generate :slack_id }
    response_url { generate :response_url }
    trigger_id { generate :trigger_id }
    private_metadata { {'intent' => 'test-intent', 'context' => {}}.to_json  }

    initialize_with{ Topic::SlackContext._from_slack_view_sumission_interaction(slack_id: slack_id, channel: channel, response_url: response_url, trigger_id: trigger_id, message_ts: message_ts) }
  end

  factory :bot_request, class: Topic::Request do
    transient do
      bot_event { build(:bot_event) }
    end

    context { Topic::SlackContext.new }
    current { bot_event } 
    trail { [ build(:bot_event).to_h ] }
    
    trait :with_event_context do
      context{ build(:event_context) }
    end

    trait :with_command_context do
      context{ build(:command_context) }
    end

    trait :with_block_actions_interaction_context do
      context{ build(:block_actions_interaction_context) }
    end

    trait :with_view_submission_interaction_event do
      context{ build(:view_submission_interaction_event) }
    end

    trait :with_message_received do
      transient do
        bot_event { build(:message_received) }
      end
    end

    trait :with_user_favourite_new do
      transient do
        bot_event { build(:user_favourite_new) }
      end
    end
    
    trait :with_user_favourites_updated do
      transient do
        bot_event { build(:user_favourites_updated) }
      end
    end
    
    trait :with_recipes_found do
      transient do
        bot_event { build(:recipes_found) }
      end
    end
    
    trait :with_favourites_found do
      transient do
        bot_event { build(:favourites_found) }
      end
    end

    trait :with_user_account_show_requested do
      transient do
        bot_event { build(:user_account_show_requested) }
      end
    end
    
    trait :with_user_account_read do
      transient do
        bot_event { build(:user_account_read, user_id: context.slack_id) }
      end
    end

    trait :with_user_account_edit_requested do
      transient do
        bot_event { build(:user_account_edit_requested) }
      end
    end

    trait :with_user_account_update_requested do
      transient do
        bot_event { build(:user_account_update_requested) }
      end
    end

    trait :with_account_show_intent do
      transient do
        trail { [ build(:user_account_show_requested).to_h ] }
      end
    end
    
    trait :with_account_edit_intent do
      transient do
        trail { [ build(:user_account_edit).to_h ] }
      end
    end

    initialize_with{ Topic::Request.new(current: current, context: context, trail: trail) }
  end

end
