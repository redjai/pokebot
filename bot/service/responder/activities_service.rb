require 'date'
require 'storage/dynamodb/team'
require 'gerty/request/events/kanbanize'
require 'gerty/service/bounded_context'
require 'service/responder/slack/response'

module Service
    module Responder
      module Actions 
        module Firehose
          module Activities
          extend self
          extend Storage::DynamoDB::Team
                                
            def listen
              [ Gerty::Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND ]
            end

            def broadcast
              []
            end

            Gerty::Service::BoundedContext.register(self)

            def call(bot_request)

              team = get_team(bot_request.data['team_id'])

              messages = bot_request.data['activities'].reverse.collect do |activity|
                firehose_text(activity)
              end

              channel = team.firehoses[bot_request.data['board_id']]

              if channel
                ::Service::Responder::Slack::Response.respond(
                  channel: channel, 
                  text: messages.join("\n")
                )
              end
            end

            def firehose_text(activity)
              "#{time(activity)}: Task #{activity['taskid']} : #{activity['event']} : #{activity['text']} : #{activity['author']}"
            end

            def time(activity)
              DateTime.parse(activity['date']).strftime('%I.%M')
            end
          end
        end
      end
    end
  end