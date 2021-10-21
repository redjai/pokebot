require 'service/responder/slack/response'
require 'gerty/service/bounded_context'
require 'gerty/request/events/users'

module Service
  module Responder
    module User 
      module KanbanizeUsernameUpdated
      extend self

        def listen
          [ Gerty::Request::Events::Users::USER_KANBANIZE_USERNAME_UPDATED ]
        end

        def broadcast
          []
        end

        Gerty::Service::BoundedContext.register(self)

        def call(bot_request)
          ::Service::Responder::Slack::Response.respond(
            channel: bot_request.context.channel, 
            text: "thanks, I have updated your kanbanize username to '#{bot_request.data['kanbanize_username']}'",
          )
        end
      end
    end
  end
end

