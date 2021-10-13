require 'service/bounded_context'
require 'service/bounded_context_loader'
require 'handlers/processors/sqs_event'

module Handler
  class Sqs

    @@loader = nil

    def self.handle(event:, context:)
      sqs_event = Handlers::SqsEvent.new(event)
      
      load_or_verify!(sqs_event)

      sqs_event.bot_requests.each do |bot_request|
        Service::BoundedContext.call(bot_request)
      end
    end

    def self.load_or_verify!(sqs_event)
      load_bounded_context!(sqs_event.event_source_arn) unless !@@loader.nil?
      verify_event_source_arn!(sqs_event.event_source_arn)   
    end

    def self.load_bounded_context!(event_source_arn)
      @@loader = Service::BoundedContextLoader.new(event_source_arn: event_source_arn)
      @@loader.load!
    end

    def self.verify_event_source_arn!(event_source_arn)
      if @@loader.event_source_arn_to_name(event_source_arn) != @@loader.name
        raise "event_source_arn '#{event_source_arn}' does not resolve to bounded_context name #{@@loader.name}"
      end
    end
  end
end