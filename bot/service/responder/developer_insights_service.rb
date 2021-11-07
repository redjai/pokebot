require 'date'
require 'gerty/request/events/insights'
require 'gerty/service/bounded_context'
require 'service/responder/slack/response'

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
                text: text( bot_request.data['activities'], bot_request.data['tasks'] )
          )
        end

        def text(activities, tasks)
          activities.sort_by{ |activity| activity['date'] }.collect do |activity|
            task = tasks.find{ |task| task['taskid'] == activity['taskid'] }
            activity_text(activity, task)
          end.join("\n\n")
        end

        def activity_text(activity, task)
          "#{activity['date']}, #{activity['event']}, #{activity['text']} #{task['title']}"
        end

      end
    end
  end
end
