require 'date'
require 'storage/kanbanize/dynamodb/client'
require 'request/events/kanbanize'
require 'service/bounded_context'
require 'slack/response'

module Service
    module Responder
      module Actions 
        module Firehose
          module Blockages
          extend self
          extend Storage::Kanbanize::DynamoDB
                                         
            def listen
              [ Request::Events::Kanbanize::NEW_ACTIVITIES_FOUND ]
            end

            def broadcast
              [] 
            end

            Service::BoundedContext.register(self)

            def call(bot_request)

              client = get_client(bot_request.data['client_id'])

              blocked_activities = bot_request.data['activities'].reverse.select do |activity|
                activity['text'] =~ /block/ || activity['event'] =~ /block/
              end

              if blocked_activities.any?

                messages = blocked_activities.collect do |activity|
                  firehose_text(activity)
                end

                ::Slack::Response.respond(
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