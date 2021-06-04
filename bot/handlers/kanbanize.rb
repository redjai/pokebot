require 'handlers/processors/sqs'

module Kanbanize  
  class Handler
    def self.handle(event:, context:)
      Bot::LOGGER.debug(event)
      Bot::LOGGER.debug(context)
      Processors::Sqs.process_cron(aws_event: event, controller: :kanbanize)
    end
  end
end
