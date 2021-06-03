require 'handlers/lambda/event'

module Responder
  class Handler
    def self.handle(event:, context:)
      Lambda::Event.process_sqs(aws_event: event, controller: :responder, accept: { 
        recipes: %w{ found },
        messages: %w{ received },
        users: %w{ favourites_updated account_updated account_read }
      })
    end
  end
end

