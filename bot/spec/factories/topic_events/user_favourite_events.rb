require 'topic/event'
require 'topic/topic'

module TopicHelper
  extend Topic::Base
end

FactoryBot.define do
  
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
  
  factory :favourites_found, class: Topic::Event do

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

  factory :slack_interaction_favourite_event, class: Topic::Event do
    initialize_with{ Topic::Slack.interaction_event(slack_favourites_interaction_event) } 
  end
end
