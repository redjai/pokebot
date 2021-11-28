
require 'gerty/request/events/cron'
require 'storage/kanbanize/dynamodb/activities'
require 'storage/kanbanize/dynamodb/tasks'

module Service
  module Insight
    module DeveloperInsights
      extend self

      def listen
        [ Gerty::Request::Events::Cron::Actions::COLUMN_STAY_INSIGHTS_BUILD_REQUESTED ]
      end

      def broadcast
        []
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        puts Storage::Kanbanize::DynamoDB::Task.column_stays(team_board_id: bot_request.data['team_board_id'])
      end
    end
  end
end