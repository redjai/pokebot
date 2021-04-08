require 'topic/event'
require 'handlers/lambda/event'
require 'topic/topic'

module User
  class Handler
    EVENTS = [Topic::Users::FAVOURITE_NEW,
              Topic::Users::FAVOURITE_DESTROY,
              Topic::Users::ACCOUNT_EDIT_REQUESTED,
              Topic::Users::ACCOUNT_SHOW_REQUESTED] 

    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :user, accept: EVENTS)
    end
  end
end
