require 'slack/response'
require 'topic/topic'
require_relative 'blocks/account'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Account 
        extend self
          
          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: 'your account:',
              blocks: Blocks::Account.new(bot_request.data['user']).blocks,
              response_url: bot_request.slack_user['response_url']
            )
          end
        end
      end
    end
  end
end
