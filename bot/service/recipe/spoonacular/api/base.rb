require 'net/http'
require 'aws-sdk-dynamodb'
require 'json'

module Service
  module Recipe
    module Spoonacular 
      module Base
        extend self

        def uri(endpoint, params)
          uri = URI(endpoint)
          params.merge!({ :apiKey => ENV['SPOONACULAR_API_KEY'] })
          uri.query = URI.encode_www_form(params)
          uri
        end

        def response(uri)
          res = Net::HTTP.get_response(uri)
          JSON.parse(res.body.force_encoding('UTF-8'))
        end
      end
    end
  end
end
