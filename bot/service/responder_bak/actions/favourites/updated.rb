require 'slack/response'

module Service
  module Responder
    module Actions 
      module Favourites
        module Updated
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.context.channel, 
              text: "favourites updated, you have #{bot_request.data['favourite_recipe_ids'].count} favourites. You can see them with the command /favourites",
            )
          end
        end
      end
    end
  end
end
