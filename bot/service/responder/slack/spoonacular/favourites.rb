require 'slack/response'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Favourites
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: "favourites updated, you have #{bot_request.data['favourite_recipe_ids'].count} favourites. You can see them with the shortcut /favourites",
            )
          end
        end
      end
    end
  end
end
