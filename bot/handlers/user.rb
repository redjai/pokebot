require 'topic/event'
require 'handlers/lambda/event'
require 'topic/topic'

module User
  class Handler
    EVENTS = [Topic::Users::FAVOURITE_NEW,
              Topic::Users::FAVOURITE_DESTROY,
              Topic::Users::ACCOUNT_EDIT,
              Topic::Users::ACCOUNT_REQUESTED] 

    def self.handle(event:, context:)
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/user/controller'
        Service::User::Controller.call(bot_request)
      end 
    end
  end
end
