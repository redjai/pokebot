require 'handlers/processors/sqs'

module Responder
  class Handler
    def self.handle(event:, context:)
      Processors::Sqs.process_sqs(aws_event: event, service: :responder, accept: { 
        recipes: %w{ found },
        messages: %w{ received },
        users: %w{ favourites_updated account_updated account_read },
        kanbanize: %w{ new_activities_found }
      })
    end
  end
end

