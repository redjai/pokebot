require 'net/http'
require_relative '../kanbanize/net/api'
require 'storage/dynamodb/team'
require 'gerty/request/events/cron'
require 'gerty/service/bounded_context'

#
# Reacts to CRON request, fetches activities from kanbanize and publishes them into a topic
# NOTE: It does not save them to storage, other services can do so if they wish.
#

module Service
  module Kanbanize
    module ImportBoardActivities # change this name 
      extend self
      extend Service::Kanbanize::Api
      extend Storage::Kanbanize::DynamoDB::Team

      DEFAULT_PAGE_SIZE = 30
                                
      def listen
        [ Gerty::Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES ]
      end

      def broadcast
        %w( kanbanize )
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        get_teams.each do |team|
          begin

            bot_request.events << Gerty::Request::Events::Kanbanize.activities_imported(
              source: :kanbanize,
              activities: activities(
                kanbanize_api_key: team.kanbanize_api_key,
                subdomain: team.subdomain,
                board_id: bot_request.data['board_id'] || team.board_id,
                event_type: bot_request.data['event_type'],
                date_range: date_range(bot_request.data['date_range'] || 'today')
              ),
              board_id: team.board_id,
              team_id: team.team_id
            )

          rescue Service::Kanbanize::Api::BadKanbanizeRequest => e
            Gerty::LOGGER.info(e.inspect)  
            Gerty::LOGGER.info(team.inspect)
          end
       
          set_last_board(team.team_id, team.board_id)
        end
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
