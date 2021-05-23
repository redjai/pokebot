require 'slack/response'
require 'topic/topic'
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
            when Topic::Users::ACCOUNT_SHOW_REQUESTED
              ::Slack::Response.respond(
                channel: bot_request.context.channel, 
                text: 'your account:',
                blocks: Service::Responder::Slack::Views::Account::Show.new(bot_request.data['user']).blocks,
              )
            when Topic::Users::ACCOUNT_EDIT_REQUESTED
              ::Slack::Response.modal(bot_request.context.trigger_id, Service::Responder::Slack::Views::Account::Edit.new(bot_request).view)
            else
              raise "Unexpected event #{bot_request}"
            end
          end
        end
      end
    end
  end
end
