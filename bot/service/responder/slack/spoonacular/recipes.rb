require 'slack/response'
require 'topic/topic'
require_relative 'blocks/recipes'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Recipes
        extend self
          
        def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: 'recipes:',
              blocks: Blocks::Recipes.new(bot_request).recipe_blocks,
              response_url: bot_request.context.response_url
            )
          end
        end
      end
    end
  end
end
