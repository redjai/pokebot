module Service
  module Responder
    module Slack
      module Account
        module Show
        extend self

          def call(bot_request)
            ::Slack::Response.respond(
              channel: bot_request.slack_user['channel'], 
              text: 'account details:',
              blocks: modal(bot_request.data['name'], bot_request.data['kanbanize_username']),
              response_url: bot_request.slack_user['response_url']
            )
          end

          def modal(handle, kanbanize_username) 
            {
              "title": {
                "type": "plain_text",
                "text": "Account"
              },
              "submit": {
                "type": "plain_text",
                "text": "Submit"
              },
              "blocks": [
                {
                  "type": "input",
                  "element": {
                    "type": "plain_text_input",
                    "action_id": "name",
                    "placeholder": {
                      "type": "plain_text",
                      "text": "What would you like me to call you ?"
                    }
                  },
                  "label": {
                    "type": "plain_text",
                    "text": "name"
                  }
                },
                {
                  "type": "input",
                  "element": {
                    "type": "plain_text_input",
                    "action_id": "kanbanize_username",
                    "placeholder": {
                      "type": "plain_text",
                      "text": "Kanbanize Username"
                    }
                  },
                  "label": {
                    "type": "plain_text",
                    "text": "Kanbanize Username"
                  }
                }
              ],
              "type": "modal"
            }

          end

        end
      end
    end
  end
end
