require_relative '../../blocks/builder'

module Service
  module Responder
    module Slack
      module Views 
        module Account
          class Show
          include Service::Responder::Slack::BlockBuilder

            def initialize(user)
              @user = user
            end

            def blocks
              [
                  account_block,
                  divider_block,
                  edit_block
              ]
            end

            def account_block
              text_section("What would you like me to call you ? #{@user['handle'] ? @user['handle'] : '[ Not told me yet ]' } Kanbanize username - #{@user['kanbanize_username']}")
            end

            def edit_block
              text_section("This is a section block with a button.", 
                           accessory: button_element(text: "Edit", 
                                                    value: { interaction: 'edit-account', data: @user['user_id'] }.to_json, 
                                                  options: { action_id: 'button-action' }))
            end
          end
        end
      end
    end
  end
end

