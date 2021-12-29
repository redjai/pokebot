require 'gerty/request/events/insights'
require 'storage/dynamodb/kanbanize/activities'
require 'storage/dynamodb/kanbanize/tasks'

module Service
  module Insight
    module DeveloperInsights
      extend self

      def listen
        [ Gerty::Request::Events::Insights::DEVELOPER_INSIGHTS_REQUESTED ]
      end

      def broadcast
        [ :insights ]
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        author = bot_request.user['kanbanize_username']
        dates = bot_request.data['date_range']
        activities = Storage::Kanbanize::DynamoDB::Activities.fetch_by_author_and_dates(author: author, dates: dates)
        
        task_ids = activities.collect do |activity|
          activity['taskid']
        end.uniq
        
        tasks = Storage::Kanbanize::DynamoDB::Task.fetch_all(bot_request.context.team_id, task_ids)

        bot_request.events << Gerty::Request::Events::Insights.developer_insights_found( source: self,
                                                                                          tasks: tasks, 
                                                                                     activities: activities )
      end
    end
  end
end
