require 'net/http'
require 'date'

module Service
  module Kanbanize
    module Api # change this name 

      def post(uri:, body:)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request(uri: uri, body: body))
        end
        response.body
      end

      def request(uri:, body:)
        req = Net::HTTP::Post.new(uri.path)
        req.body = body.to_json
        headers.each do |key, value|
          req[key] = value
        end
        req
      end

      def uri(function:)
        URI("https://#{ENV['KANBANIZE_SUBDOMAIN']}.kanbanize.com/index.php/api/kanbanize/#{function}/")
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

      def headers
        {
          'Content-Type' => 'application/json',
          'Accept' => 'application/json',
          'apiKey' => ENV['KANBANIZE_API_KEY'] 
        }
      end
    end
  end
end
