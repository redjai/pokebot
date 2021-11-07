require 'gerty/request/events/insights'
require 'gerty/request/events/messages'

module Service
  module Intent
    module DeveloperInsights
      extend self

      def listen
        [ Gerty::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :insights ]
      end

      Gerty::Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /(|me|team) (|today|yesterday|this week|last week)\s*$/
          bot_request.events << Gerty::Request::Events::Insights.developer_insights_requested(source: self, target: $1, date_range: $2)
        end
      end 

    end
  end
end
