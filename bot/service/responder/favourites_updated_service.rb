require 'service/responder/slack/response'
require 'gerty/request/events/users'

module Service
  module Responder
    module Actions 
      module Favourites
        module Updated
        extend self

          def listen
            [ Gerty::Request::Events::Users::FAVOURITES_UPDATED ]
          end

          def broadcast
            []
          end

          Gerty::Service::BoundedContext.register(self)

          def call(bot_request)
            ::Service::Responder::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: "I've updated your favourite recipes, you now have #{bot_request.data['favourite_recipe_ids'].count} favourites. You can see them by askimg me for 'my favourites'",
            )
          end
        end
      end
    end
  end
end
