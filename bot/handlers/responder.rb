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
      Lambda::Event.process_sqs(aws_event: event, controller: :responder, accept: { 
        recipes: %w{ found },
        messages: %w{ received },
        users: %w{ favourites_updated account_updated account_read }
      })
    end
  end
end

