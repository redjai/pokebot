require 'net/http'
require 'date'
require 'json'

module Service
  module Kanbanize
    module Api # change this name 

      def post(kanbanize_api_key:,uri:, body:)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request(kanbanize_api_key: kanbanize_api_key, uri: uri, body: body))
        end
        raise response.body unless response.code == "200"
        JSON.parse(response.body)
      end

      def request(kanbanize_api_key:, uri:, body:)
        req = Net::HTTP::Post.new(uri.path)
        req.body = body.to_json
        headers(kanbanize_api_key).each do |key, value|
          req[key] = value
        end
        req
      end

      def uri(subdomain:, function:)
        URI("https://#{subdomain}.kanbanize.com/index.php/api/kanbanize/#{function}/")
      end

      def today
        {
          from: argdate(Date.today),
          to: argdate(Date.today + 1)
        }
      end

      def yesterday
        {
          from: argdate(Date.today - 1),
          to: argdate(Date.today)
        }
      end

      def argdate(date)
        date.strftime("%Y-%m-%d")
      end

      def headers(kanbanize_api_key)
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'apiKey' => kanbanize_api_key
        }
      end
    end
  end
end
