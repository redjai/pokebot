require 'request/event'
require 'request/events/users'
require 'request/events/recipes'

module TopicHelper
  extend Request::Base
end

FactoryBot.define do
  
  factory :user_favourite_new, class: ::Request::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ ::Request::Events::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourite_destroy, class: ::Request::Event do

    source { :test_source }
    favourite_recipe_id { 'test-recipe-id-123' }

    initialize_with{ ::Request::Events::Users.favourite_new(source: source, favourite_recipe_id: favourite_recipe_id) }

  end

  factory :user_favourites_updated, class: ::Request::Event do

    source { :test_source }
    favourite_recipe_ids { [ generate(:recipe_id) ] }

    initialize_with{ ::Request::Events::Users.favourites_updated(source: source, favourite_recipe_ids: favourite_recipe_ids) }

  end
  
  factory :favourites_found, class: ::Request::Event do

    source { :test_source }
    recipes { Factory::Support::Spoonacular.information_bulk_beef_rendang }
    favourite_recipe_ids { [ generate(:recipe_id) ]  }
    query { }
    offset { }
    per_page { }
    total_results { }

    initialize_with{ ::Request::Events::Recipes.found( source: source, 
                                          recipes: recipes, 
                                            query: query, 
                             favourite_recipe_ids: favourite_recipe_ids, 
                                           offset: offset, 
                                         per_page: per_page, 
                                    total_results: total_results ) }

  end

end
