require 'handlers/lambda/event'
require 'topic/topic'

module Notifier 
  class Handler
    EVENTS = [Topic::Users::FAVOURITES_UPDATED]

    def self.handle(event:, context:)
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/notifications/controller'
        Service::Notifications::Controller.call(bot_request)
      end 
    end
  end
end

