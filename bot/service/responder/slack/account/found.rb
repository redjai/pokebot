require_relative '../../spoonacular/blocks/account'

module Service
  module Responder
    module Slack
      module Account
        module Found
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: 'account details:',
              blocks: modal(bot_request.data['name'], bot_request.data['kanbanize_username']),
              response_url: bot_request.slack_user['response_url']
            )
          end

        end
      end
    end
  end
end
