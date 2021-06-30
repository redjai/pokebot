require 'handlers/processors/cron'

module Kanbanize  
  module Cron
    class Handler
      def self.handle(event:, context:)
        Bot::LOGGER.debug(event)
        Bot::LOGGER.debug(context)
        Processors::Cron.process(aws_event: event, controller: :kanbanize)
      end
    end
  end
end
