require 'date'
require 'json'
require 'net/http'

module Service
  module Kanbanize
    module Api # change this name 

      class BadKanbanizeRequest < StandardError

        attr_accessor :code

        def initialize(code, message)
          super(message)
          @code = code
        end

      end

      def post(kanbanize_api_key:,uri:, body:)
        response = Net::HTTP.start(uri.hostname, uri.port, use_ssl: true) do |http|
          http.request(request(kanbanize_api_key: kanbanize_api_key, uri: uri, body: body))
        end
        raise BadKanbanizeRequest.new(response.code, response.body) unless response.code == "200"
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

      def date_range(arg)
        case arg
        when 'today'
          today
        when 'yesterday'
          yesterday
        else
          parse_date_range(arg)   
        end
      end

      def today
        {
          from: argdate(Date.today - ENV['DATE_RANGE_OFFSET'].to_i),
          to: argdate(Date.today  - ENV['DATE_RANGE_OFFSET'].to_i + 1)
        }
      end

      def yesterday
        {
          from: argdate(Date.today - 1),
          to: argdate(Date.today)
        }
      end

      def parse_date_range(arg)
        raise "cannot parse date range unexpected value #{arg}" unless arg.include?("..")
        dates = arg.split("..")
        { 
          from: dates.first,
          to: dates.last
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
