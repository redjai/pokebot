require 'net/http'
require 'json'

module Pokebot
  module Service
    module Bot
      extend self

      def call(event)
        event['state']['bot'] = {
                                   'spoonacular' => { 
                                     'search' => search(slack_text(event)) 
                                   }
                                }
      end

      def search(text)
        response(search_uri(text))
      end

      def slack_text(event)
        event['state']['slack']['event']['text'].gsub(/<[^>]+>/,"").strip
      end

      def response(uri)
        res = Net::HTTP.get_response(uri)
        puts res['X-API-Quota-Request']
        puts res['X-API-Quota-Used']

        puts res.body

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

      def bulk_recipe_uri(ids)
        URI('https://api.spoonacular.com/recipes/informationBulk')
      end
    end
  end
end
