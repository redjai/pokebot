require 'gerty/request/event'
require 'handlers/processors/sqs'

module User
  class Handler
    def self.handle(event:, context:)
      Processors::Sqs.process_sqs(aws_event: event, service: :user, accept: {
        users: %w{ favourite_new favourite_destroy account_edit_requested account_show_requested account_update_requested }
      })
    end
  end
end
