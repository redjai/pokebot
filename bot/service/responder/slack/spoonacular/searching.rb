require 'slack/response'

module Service
  module Responder
    module Slack
      module Spoonacular
        module Searching
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: "searching for #{bot_request.data['text']} recipes... :male-cook: :knife_fork_plate: :female-cook:",
            )
          end
        end
      end
    end
  end
end
