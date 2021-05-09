require 'topic/event'
require 'topic/topic'

FactoryBot.define do

  factory :bot_request, class: Topic::Request do
    transient do
      bot_event { build(:bot_event) }
    end

    context { Topic::SlackContext.new(slack_id: 'UTESTSLACK123', channel: 'CTESTSLACK234', trigger_id: 'test-trigger-id-123') }
    current { bot_event } 
    trail { [ build(:bot_event).to_h ] }
   
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
