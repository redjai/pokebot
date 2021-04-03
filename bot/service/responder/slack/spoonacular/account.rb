require 'slack/response'
require 'topic/topic'
require_relative 'blocks/account/show'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Account 
        extend self
          
          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: 'your account:',
              blocks: Blocks::Account::Show.new(bot_request.data['user']).blocks,
              response_url: bot_request.context.response_url
            )
          end
        end
      end
    end
  end
end
