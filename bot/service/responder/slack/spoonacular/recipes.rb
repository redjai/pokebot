require 'slack/response'
require_relative 'blocks' 
require 'topic/topic'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Recipes
        extend self
          
        def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: 'recipes:',
              blocks: Blocks.new(bot_request).recipe_blocks,
              response_url: bot_request.slack_user['response_url']
            )
          end
        end
      end
    end
  end
end
