require 'net/http'
require_relative 'api'
require_relative 'client'
require 'request/events/kanbanize'
require 'topic/sns'

module Service
  module Kanbanize
    module ImportBoardActivities # change this name 
      extend self
      extend Service::Kanbanize::Api
      extend Service::Kanbanize::Storage

      DEFAULT_PAGE_SIZE = 30

      def call(bot_request)

        client = get_client(bot_request.data['client_id'])

        begin

          bot_request.current = ::Request::Events::Kanbanize.activities_imported(
            source: :kanbanize,
            activities: activities(
              kanbanize_api_key: client.kanbanize_api_key,
              subdomain: client.subdomain,
              board_id: bot_request.data['board_id'] || client.board_id,
              event_type: bot_request.data['event_type'],
              date_range: date_range(bot_request.data['date_range'] || :today)
            ),
            board_id: client.board_id,
            client_id: client.id
          )

          Topic::Sns.broadcast(
            topic: :kanbanize,
            request: bot_request
          )

        rescue Service::Kanbanize::Api::BadKanbanizeRequest => e
          Bot::LOGGER.info(e.inspect)  
          Bot::LOGGER.info(client.inspect)
        end
       
        set_last_board(client.id, client.board_id)
      end

      def activities(kanbanize_api_key:, subdomain:, board_id:, event_type:, date_range:) 
        uri = uri(subdomain: subdomain, function: :get_board_activities)
        activities = []
        page = 1
        loop do
          body = body(board_id: board_id, from_date: date_range[:from], to_date: date_range[:to], event_type: event_type, page: page)
          result = post(kanbanize_api_key: kanbanize_api_key, uri: uri, body: body)
          activities += result['activities']
          break unless result["allactivities"].to_i > page.to_i * page_size.to_i
          page += 1
        end 
        activities
      end

      def body(board_id:, from_date:, to_date:, event_type:, page:)
        { boardid: board_id, fromdate: from_date, todate: to_date, eventtype:  event_type, page: page, resultsperpage: page_size }
      end

      def page_size
        ENV['PAGE_SIZE'] || DEFAULT_PAGE_SIZE
      end

    end
  end
end
