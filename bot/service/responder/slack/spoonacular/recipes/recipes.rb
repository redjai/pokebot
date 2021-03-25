require 'slack/response'
require_relative 'blocks' 
require 'topic/topic'

module Service
  module Responder
    module Slack
      module Recipes
        module Spoonacular
          module Respond
          extend self
          
            def call(bot_request)
              case bot_request.name
              when Topic::Recipes::FOUND
                respond_with_recipes(bot_request)
              when Topic::Messages::RECEIVED
                respond_searching(bot_request)
              else
                raise "unexpected event name #{bot_request.name}"
              end
            end

            def respond_searching(bot_request)
              ::Slack::Response.respond(
                channel: bot_request.slack_user['channel'], 
                text: "searching for #{bot_request.data['text']} recipes... :male-cook: :knife_fork_plate: :female-cook:",
              )
            end

            def respond_with_recipes(bot_request)
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
end
