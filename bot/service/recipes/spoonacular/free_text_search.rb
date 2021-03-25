require 'topic/sns'
require_relative 'api/complex_search'
require_relative '../user'
require_relative 'api/information_bulk_search'
require 'topic/topic'

module Service
  module Recipe
    module Spoonacular 
      module FreeTextSearch
        extend self

        def call(bot_request)
          complex_search = Service::Recipe::Spoonacular::ComplexSearch.search_free_text(
                                                                                          bot_request.data['query'],
                                                                                          bot_request.data['page']['offset'], 
                                                                                          bot_request.data['page']['per_page']
                                                                                       )
          bot_request.current = Topic::Recipes::found(
                              source: :recipes,
                             recipes: information_bulk_result(complex_search),
                favourite_recipe_ids: Service::Recipe::User.recipe_ids(bot_request.slack_user['slack_id']),
                               query: bot_request.data['query'],
                              offset: bot_request.data['page']['offset'], 
                            per_page: bot_request.data['page']['per_page'],
                       total_results: complex_search['totalResults']
                                                                         )
          Topic::Sns.broadcast(topic: :recipes, event: bot_request)
        end

        def information_bulk_result(search_result)
          if search_result['totalResults'] > 0
             search_result_ids = Service::Recipe::Spoonacular::ComplexSearch.ids_from_complex_search_result(search_result)
             Service::Recipe::Spoonacular::InformationBulkSearch.search_by_ids(search_result_ids)
          else
             []
          end
        end
      end
    end
  end
end
