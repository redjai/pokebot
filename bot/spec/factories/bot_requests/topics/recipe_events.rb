require 'gerty/request/event'
require 'gerty/request/events/slack'
require 'gerty/request/events/recipes'
require 'gerty/request/events/messages'

module TopicHelper
  extend Gerty::Request::Base
end

FactoryBot.define do

  sequence(:recipe_id) { |n| "test-recipe-id-#{n}" }
  


  factory :message_received, class: ::Gerty::Request::Event do

    source { :test_source }
    text { 'some test text' }

    initialize_with{ Gerty::Request::Events::Messages.received(source: source, text: text) }

  end
  
  factory :recipes_found, class: ::Gerty::Request::Event do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { "beef rendang" }
    offset { 0 }
    per_page { 10 }
    total_results { 1 }

    initialize_with{ Gerty::Request::Events::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end
  
  factory :slack_event_api_recipe_search_event, class: ::Gerty::Request::Event do
    initialize_with{ Gerty::Request::Events::Slack.api_event(recipe_search_api_event) } 
  end
end
