module Service
  module Responder
    module Slack
      module Spoonacular
        module Blocks
          module Account
            class Show

              def initialize(user)
                @user = user
              end

              def blocks
                [
                    account_block,
                    divider,
                    edit_block
                ]
              end

              def account_block
                {
                  "type" => "section",
                  "text" => {
                    "type" => "mrkdwn",
                    "text" => "What would you like me to call you ? #{@user['handle'] ? @user['handle'] : '[ Not told me yet ]' } Kanbanize username - #{@user['kanbanize_username']}"
                  }
                }
              end

              def divider
                {
                  "type" => "divider"
                }
              end

              def edit_block
                {
                  "type" => "section",
                  "text" => {
                    "type" => "mrkdwn",
                    "text" => "This is a section block with a button."
                  },
                  "accessory" => {
                    "type" => "button",
                    "text" => {
                      "type" => "plain_text",
                      "text" => "Edit",
                      "emoji" => true
                    },
                    "value" => { interaction: 'edit-account', data: @user['user_id'] }.to_json,
                    "action_id" => "button-action"
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

