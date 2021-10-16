require 'slack/response'
require 'gerty/request/events/users'
require_relative '../../slack/views/account/show'
require_relative '../../slack/views/account/edit'

module Service
  module Responder
    module Actions
      module Account
        module Read 
        extend self
          
          def call(bot_request)
            case bot_request.intent['name']
            when Gerty::Request::Events::Users::ACCOUNT_SHOW_REQUESTED
              ::Slack::Response.respond(
                channel: bot_request.context.channel, 
                text: 'your account:',
                blocks: Service::Responder::Slack::Views::Account::Show.new(bot_request.data['user']).blocks,
              )
            when Gerty::Request::Events::Users::ACCOUNT_EDIT_REQUESTED
              ::Slack::Response.delete(channel: bot_request.context.channel, ts: bot_request.context.message_ts)
              ::Slack::Response.modal(bot_request.context.trigger_id, Service::Responder::Slack::Views::Account::Edit.new(bot_request).view)
            else
              raise "Unexpected intent #{bot_request.intent['name']}"
            end
          end
        end
      end
    end
  end
end
