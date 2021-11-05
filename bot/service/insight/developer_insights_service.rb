require 'gerty/request/events/insights'
require 'storage/kanbanize/dynamodb/activities'

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
        dates = bot_request.data['date_range'].to_sym
        puts Storage::Kanbanize::DynamoDB::Activities.fetch_by_author_and_dates(author: author, dates: dates).inspect
      end 

    end
  end
end
