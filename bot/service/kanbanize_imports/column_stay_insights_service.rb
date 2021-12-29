
require 'gerty/request/events/cron'
require 'storage/dynamodb/kanbanize/activities'
require 'storage/dynamodb/kanbanize/tasks'
require_relative 'insights/column_stay_insights'
require 'descriptive_statistics'

module Service
  module Insight
    module DeveloperInsights
      extend self

      def listen
        [ Gerty::Request::Events::Cron::Actions::COLUMN_STAY_INSIGHTS_BUILD_REQUESTED ]
      end

      def broadcast
        [ :insights ]
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        date_range = last_90_days
        team_board_id = bot_request.data['team_board_id']
        stays = Storage::Kanbanize::DynamoDB::Task.board_column_stays(team_board_id: team_board_id, date_range: date_range)
        puts Service::Insight::ColumnStayInsights.new(team_board_id, stays).to_h
      end

      def last_90_days
        ((Date.today - 90)..Date.today)
      end
    end
  end
end