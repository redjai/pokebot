require 'date'
require 'storage/dynamodb/team'
require 'gerty/request/events/kanbanize'
require 'gerty/service/bounded_context'
require 'service/responder/slack/response'

module Service
    module Responder
      module Actions 
        module Firehose
          module Blockages
          extend self
          extend ::Storage::DynamoDB::Team                                         
            def listen
              [ Gerty::Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND ]
            end

            def broadcast
              [] 
            end

            Gerty::Service::BoundedContext.register(self)

            def call(bot_request)

              client = get_team(bot_request.data['team_id'])

              blocked_activities = bot_request.data['activities'].reverse.select do |activity|
                activity['text'] =~ /block/ || activity['event'] =~ /block/
              end

              if blocked_activities.any?

                messages = blocked_activities.collect do |activity|
                  firehose_text(activity)
                end

                ::Service::Responder::Slack::Response.respond(
                  channel: client.blockages_channel, 
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