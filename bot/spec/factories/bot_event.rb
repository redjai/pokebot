require 'topic/event'
require 'topic/topic'

FactoryBot.define do

  sequence(:recipe_id) { |n| "test-recipe-id-#{n}" }
  
  factory :bot_event, class: Topic::Event do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ Topic::Event.new(source: source, name: name, version: version, data: data) }

  end

  factory :message_received, class: Topic::Event do

    source { :test_source }
    text { 'some test text' }

    initialize_with{ Topic::Messages.received(source: source, text: text) }

  end
  
  factory :user_favourite_new, class: Topic::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ Topic::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourite_destroy, class: Topic::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ Topic::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourites_updated, class: Topic::Event do

    source { :test_source }
    favourite_recipe_ids { [ generate(:recipe_id) ] }

    initialize_with{ Topic::Users.favourites_updated(source: source, favourite_recipe_ids: favourite_recipe_ids) }

  end

  factory :user_account_requested, class: Topic::Event do

    source { :test_source }

    initialize_with{ Topic::Users.account_requested(source: source) }

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

  factory :user_account_edit, class: Topic::Event do

    source { :test_source }

    initialize_with{ Topic::Users.account_edit(source: source) }

  end

  factory :user_account_update, class: Topic::Event do

    source { :test_source }
    handle { 'test handle' }
    kanbanize_username { 'test-kanbanze-username' }

    initialize_with{ Topic::Users.account_update(source: source, handle: handle, kanbanize_username: kanbanize_username) }

  end

  factory :recipes_found, class: Topic::Request do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { "beef rendang" }
    offset { 0 }
    per_page { 10 }
    total_results { 1 }

    initialize_with{ Topic::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end

  factory :favourites_found, class: Topic::Request do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { }
    offset { }
    per_page { }
    total_results { }

    initialize_with{ Topic::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end

  factory :bot_request, class: Topic::Request do
    transient do
      bot_event { build(:bot_event) }
    end

    context { Topic::SlackContext.new(slack_id: 'UTESTSLACK123', channel: 'CTESTSLACK234') }
    current { bot_event } 
    trail { [ build(:bot_event) ] }
   
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

    trait :with_user_account_requested do
      transient do
        bot_event { build(:user_account_requested) }
      end
    end
    
    trait :with_user_account_read do
      transient do
        bot_event { build(:user_account_read, user_id: context.slack_id) }
      end
    end

    trait :with_user_account_edit do
      transient do
        bot_event { build(:user_account_edit) }
      end
    end
    
    trait :with_user_account_update do
      transient do
        bot_event { build(:user_account_update) }
      end
    end

    initialize_with{ Topic::Request.new(current: current, context: context, trail: trail) }
  end

end
