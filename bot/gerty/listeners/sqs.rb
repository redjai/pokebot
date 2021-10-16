require 'gerty/service/bounded_context'
require 'gerty/service/bounded_context_loader'
require 'gerty/listeners/records/sqs'

module Handler
  class Sqs

    @@loader = nil

    def self.handle(event:, context:)
      sqs_records = Gerty::Listeners::Records::Sqs.new(event)
      
      load_or_verify!(sqs_records)

      sqs_records.bot_requests.each do |bot_request|
        Gerty::Service::BoundedContext.call(bot_request)
      end
    end

    def self.load_or_verify!(sqs_records)
      load_bounded_context!(sqs_records.event_source_arn) unless !@@loader.nil?
      verify_event_source_arn!(sqs_records.event_source_arn)   
    end

    def self.load_bounded_context!(event_source_arn)
      @@loader = Gerty::Service::BoundedContextLoader.new(event_source_arn: event_source_arn)
      @@loader.load!
    end

    def self.verify_event_source_arn!(event_source_arn)
      if @@loader.event_source_arn_to_name(event_source_arn) != @@loader.name
        raise "event_source_arn '#{event_source_arn}' does not resolve to bounded_context name #{@@loader.name}"
      end
    end
  end
end