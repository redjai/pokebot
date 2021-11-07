require 'date'
require 'gerty/request/events/insights'
require 'gerty/service/bounded_context'
require 'service/responder/slack/response'
require 'service/responder/slack/views/insights/developer'

module Service
  module Responder
    module Actions 
      module DeveloperInsightsService
        extend self

        def listen
          [ Gerty::Request::Events::Insights::DEVELOPER_INSIGHTS_FOUND ]
        end

        def broadcast
          []
        end

        Gerty::Service::BoundedContext.register(self)

        def call(bot_request)
          ::Service::Responder::Slack::Response.respond(
            channel: bot_request.context.channel, 
               text: 'your activities last week',
             blocks: Service::Responder::Slack::Views::Insights::Developer.new(bot_request).insight_blocks
          )
        end
      end
    end
  end
end
