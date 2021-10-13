require 'handlers/processors/sqs'

module Intent
  class Handler   
    def self.handle(event:, context:)
      bot_request = Processors::Sqs.bot_requests(event).each do |bot_request|
        Service::BoundedContext.call(bot_request)
      end
    end
  end
end
