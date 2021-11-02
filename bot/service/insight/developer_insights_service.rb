require 'gerty/request/events/insights'

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
        puts "Insights...."
      end 

    end
  end
end
