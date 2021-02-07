require 'net/http'
require 'json'
require 'pokebot/topic/sns'

module Pokebot
  module Service
    module Spoonacular 
      extend self

      def call(event)
        event.recipes = recipes(event.slack_text)
        Pokebot::Topic::Sns.broadcast(
          topic: :responses, 
          event: Pokebot::Lambda::Event::RECIPES_FOUND,  
          state: event.state
        )
      end

      def recipes(text)
        search_result = search(text)
        bulk_result = information_bulk(ids(search_result))
        {
          'search' => search_result,
          'information_bulk' => bulk_result
        }
      end

      def search(text)
        response(search_uri(text))
      end

      def information_bulk(ids)
        response(bulk_recipe_uri(ids))
      end

      def response(uri)
        res = Net::HTTP.get_response(uri)
        JSON.parse(res.body.force_encoding('UTF-8'))
      end

      def search_uri(text)
        params = { :query => text }
        uri('https://api.spoonacular.com/recipes/complexSearch', params)
      end

      def uri(endpoint, params)
        uri = URI(endpoint)
        params.merge!({ :apiKey => ENV['SPOONACULAR_API_KEY'] })
        uri.query = URI.encode_www_form(params)
        uri
      end

      def ids(complex_search_result)
        complex_search_result['results'].collect do |result|
          result['id']
        end
      end

      def bulk_recipe_uri(ids)
        uri('https://api.spoonacular.com/recipes/informationBulk', ids_query(ids))
      end

      def ids_query(ids)
        { :ids => ids.join(",") }
      end
    end
  end
end
