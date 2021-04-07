require 'slack/response'
require 'topic/topic'
require_relative 'blocks/account/show'
require_relative 'blocks/account/edit'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Account 
        extend self
          
          def call(bot_request)
            case bot_request.intent['name']
            when Topic::Users::ACCOUNT_SHOW_REQUESTED
              ::Slack::Response.respond(
                channel: bot_request.context.channel, 
                text: 'your account:',
                blocks: Blocks::Account::Show.new(bot_request.data['user']).blocks,
              )
            when Topic::Users::ACCOUNT_EDIT_REQUESTED
              ::Slack::Response.modal(
                trigger_id: bot_request.context.trigger_id,
                view: Blocks::Account::Edit.new(bot_request.context.trigger_id, bot_request).view 
              )
            else
              raise "Unexpected event #{bot_request}"
            end
          end
        end
      end
    end
  end
end
