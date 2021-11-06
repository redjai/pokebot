require 'gerty/request/events/insights'
require 'storage/kanbanize/dynamodb/activities'
require 'storage/kanbanize/dynamodb/tasks'

module Service
  module Insight
    module DeveloperInsights
      extend self

      def listen
        [ Gerty::Request::Events::Insights::ACTIVITIES_REQUESTED ]
      end

      def broadcast
        []
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        author = bot_request.user['kanbanize_username']
        dates = bot_request.data['date_range']
        activities = Storage::Kanbanize::DynamoDB::Activities.fetch_by_author_and_dates(author: author, dates: dates)
        
        task_ids = activities.collect do |activity|
          activity['taskid']
        end
        puts Storage::Kanbanize::DynamoDB::Task.fetch_all(bot_request.context.team_id, task_ids).inspect
      end
    end
  end
end
