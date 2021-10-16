require 'service/responder/slack/response'

module Service
  module Responder
    module Actions
      module Account
        module Updated 
        extend self
          def call(bot_request)
            ::Service::Responder::Slack::Response.respond(
              channel: bot_request.context.private_metadata['context']['channel'], 
              text: "Thanks #{bot_request.data['handle']}, I've updated your details"
            )
          end
        end
      end
    end
  end
end

