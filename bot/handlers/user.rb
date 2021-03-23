require 'topic/event'
require 'handlers/lambda/event'

module User
  class Handler
    EVENTS = [Topic::USER_FAVOURITE_NEW, Topic::USER_FAVOURITE_DESTROY] 

    def self.handle(event:, context:)
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/user/controller'
        Service::User::Controller.call(bot_request)
      end 
    end
  end
end
