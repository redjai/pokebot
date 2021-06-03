require 'slack/response'
require 'request/events/topic'
require_relative '../../slack/views/recipes/index'

module Service
  module Responder
    module Actions 
      module Recipes
        module Index
        extend self
          
        def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: 'recipes:',
              blocks: Service::Responder::Slack::Views::Recipes::Index.new(bot_request).recipe_blocks,
              response_url: bot_request.context.response_url
            )
          end
        end
      end
    end
  end
end
