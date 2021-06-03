require 'request/event'
require 'handlers/lambda/event'

module User
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :user, accept: {
        users: %w{ favourite_new favourite_destroy account_edit_requested account_show_requested account_update_requested }
      })
    end
  end
end
