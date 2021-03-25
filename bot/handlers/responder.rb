require 'handlers/lambda/event'
require 'topic/topic'

module Responder
  class Handler
    EVENTS = [
               Topic::Recipes::FOUND, 
               Topic::Messages::RECEIVED, 
               Topic::Users::FAVOURITES_UPDATED
             ]

    def self.handle(event:, context:)
      Lambda::Event.each_sqs_record_bot_request(aws_event: event, accept: EVENTS) do |bot_request|
        require 'service/responder/controller'
        Service::Responder::Controller.call(bot_request)
      end 
    end
  end
end

