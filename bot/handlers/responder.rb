require 'handlers/lambda/event'
require 'topic/topic'

module Responder
  class Handler
    EVENTS = [
               Topic::Recipes::FOUND, 
               Topic::Messages::RECEIVED, 
               Topic::Users::FAVOURITES_UPDATED,
               Topic::Users::ACCOUNT_UPDATED,
               Topic::Users::ACCOUNT_READ
             ]

    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :responder, accept: [
        "recipes#found",
        "messages#received",
        "users#favourites_updated",
        "users#account_updated",
        "users#account_read"
      ])
    end
  end
end

