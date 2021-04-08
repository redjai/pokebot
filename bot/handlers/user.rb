require 'topic/event'
require 'handlers/lambda/event'
require 'topic/topic'

module User
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :user, accept: [
        "users#favourite_new",
        "users#favourite_destroy",
        "users#account_edit_requested",
        "users#account_show_requested"
      ])
    end
  end
end
