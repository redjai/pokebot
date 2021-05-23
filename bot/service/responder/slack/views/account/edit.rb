require_relative "../../blocks/builder"

module Service
  module Responder
    module Slack
      module Views
        module Account
          class Edit

            def initialize(bot_request)
              @bot_request = bot_request 
            end

            def view
              modal = Service::Responder::Slack::Modal.new("Your account", private_metadata, "Submit")
              modal.add_input(label: "handle", initial_value: handle, placeholder: "what would you like me to call you ?" , action_id: "edit-handle")
              modal.add_input(label: "email", initial_value: email, placeholder: "your email", action_id: "edit-email")
              modal.add_input(label: "kanbanize", initial_value: kanbanize_username, placeholder: "kanbanize username" ,action_id: "edit-kanbanize")
              modal.view
            end

            def private_metadata
              { "intent" => 'update-user-account', "context" => @bot_request.context.to_h }.to_json
            end

            def user
              @bot_request.data['user']
            end

            def email
              user['email']
            end

            def handle
              user['handle']
            end

            def kanbanize_username
              user['kanbanize_username']
            end

          end
        end
      end
    end
  end
end
