require 'slack/response'
require 'service/bounded_context'
require 'gerty/request/events/messages'

module Service
  module Responder
    module Actions 
      module Searching
        module Index
        extend self

          def listen
            [ Gerty::Request::Events::Messages::RECEIVED ]
          end

          def broadcast
            []
          end

          BoundedContext.register(self)

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
