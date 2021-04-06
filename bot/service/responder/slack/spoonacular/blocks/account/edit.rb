module Service
  module Responder
    module Slack
      module Spoonacular
        module Blocks
          module Account
            class Edit

              def initialize(trigger_id, bot_request)
                @trigger_id = trigger_id
              end

              def view
                {
                          "type": "modal",
                   "callback_id": "modal-identifier",
                         "title": {
                            "type": "plain_text",
                            "text": "Just a modal"
                          },
                         blocks: blocks
                }

              end

              def blocks
                [
                  handle_section
                ]
              end

              def handle_section
                {
                  "type": "section",
                  "block_id": "section-identifier",
                  "text": {
                    "type": "mrkdwn",
                    "text": "*Welcome* to ~my~ Block Kit _modal_!"
                  }
                }
              end

            end
          end
        end
      end
    end
  end
end
