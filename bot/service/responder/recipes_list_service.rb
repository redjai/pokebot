require 'service/responder/slack/response'
require_relative 'slack/views/recipes/index'
require 'gerty/request/events/recipes'

module Service
  module Responder
    module Actions 
      module Recipes
        module Index
        extend self

        def listen
          [ Gerty::Request::Events::Recipes::FOUND ]
        end

        def broadcast
          []
        end

       Gerty::Service::BoundedContext.register(self)
          
        def call(bot_request)
            ::Service::Responder::Slack::Response.respond(
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
