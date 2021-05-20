require_relative "../../../block_builder"

module Service
  module Responder
    module Slack
      module Spoonacular
        module Blocks
          module Account
            class Edit

              def initialize(bot_request)
                @bot_request = bot_request 
              end

              def view
                modal = Service::Responder::Slack::Modal.new("Your account","edit-user-account" ,"Submit")
                modal.add_input("handle", "Your Name here", "edit-handle")
                modal.add_input("email", "Your Email here", "edit-email")
                modal.add_input("kanbanize", "Your Kanbanize username here", "edit-kanbanize")
                modal.view
              end

            end
          end
        end
      end
    end
  end
end
