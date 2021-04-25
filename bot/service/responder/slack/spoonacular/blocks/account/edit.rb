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
                  "label": {
                    "type": "plain_text",
                    "text": "Label of input"
                  },
                  "element": {
                    "type": "plain_text_input",
                    "action_id": "plain_input",
                    "placeholder": {
                      "type": "plain_text",
                      "text": "Enter some plain text"
                    }
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
