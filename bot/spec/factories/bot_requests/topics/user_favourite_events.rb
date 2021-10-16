require 'gerty/request/event'
require 'gerty/request/events/users'
require 'gerty/request/events/recipes'

module TopicHelper
  extend Gerty::Request::Base
end

FactoryBot.define do
  
  factory :user_favourite_new, class: ::Gerty::Request::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ Gerty::Request::Events::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourite_destroy, class: ::Gerty::Request::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ Gerty::Request::Events::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourites_updated, class: ::Gerty::Request::Event do

    source { :test_source }
    favourite_recipe_ids { [ generate(:recipe_id) ] }

    initialize_with{ Gerty::Request::Events::Users.favourites_updated(source: source, favourite_recipe_ids: favourite_recipe_ids) }

  end
  
  factory :favourites_found, class: ::Gerty::Request::Event do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { }
    offset { }
    per_page { }
    total_results { }

    initialize_with{ Gerty::Request::Events::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end

end
