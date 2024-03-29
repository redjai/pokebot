require 'service/responder/slack/response'
require 'gerty/service/bounded_context'
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

         Gerty::Service::BoundedContext.register(self)

          def call(bot_request)
            ::Service::Responder::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: ":smiley:  _#{bot_request.data['text']}_...\n...helping you is what I do !",
            )
          end
        end
      end
    end
  end
end
