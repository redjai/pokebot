require 'request/event'
require 'request/events/slack'
require 'request/events/recipes'
require 'request/events/messages'

module TopicHelper
  extend Request::Base
end

FactoryBot.define do

  sequence(:recipe_id) { |n| "test-recipe-id-#{n}" }
  
  factory :bot_event, class: ::Request::Event do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ ::Request::Event.new(source: source, name: name, version: version, data: data) }

  end

  factory :message_received, class: ::Request::Event do

    source { :test_source }
    text { 'some test text' }

    initialize_with{ ::Request::Events::Messages.received(source: source, text: text) }

  end
  
  factory :recipes_found, class: ::Request::Event do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { "beef rendang" }
    offset { 0 }
    per_page { 10 }
    total_results { 1 }

    initialize_with{ ::Request::Events::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end
  
  factory :slack_event_api_recipe_search_event, class: ::Request::Event do
    initialize_with{ ::Request::Events::Slack.api_event(recipe_search_api_event) } 
  end
end
