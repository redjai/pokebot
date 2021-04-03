require 'slack/response'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Searching
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: ":smiley:  _#{bot_request.data['text']}_...\n...helping you is what I do !",
            )
          end
        end
      end
    end
  end
end
