require 'slack/response'
require 'request/events/users'

module Service
  module Responder
    module Actions 
      module Favourites
        module Updated
        extend self

          def listen
            [ ::Request::Events::Users::FAVOURITES_UPDATED ]
          end

          def broadcast
            []
          end

          Service::BoundedContext.register(self)

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: "I've updated your favourite recipes, you now have #{bot_request.data['favourite_recipe_ids'].count} favourites. You can see them by askimg me for 'my favourites'",
            )
          end
        end
      end
    end
  end
end
