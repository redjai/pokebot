require 'handlers/processors/util'

module Kanbanize  
  module Util 
    class Handler
      def self.handle(event:, context:)
        Bot::LOGGER.debug(event)
        Bot::LOGGER.debug(context)
        Processors::Util.process(aws_event: event, controller: :controller_util, service: :kanbanize)
      end
    end
  end
end
