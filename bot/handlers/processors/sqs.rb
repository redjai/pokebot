require 'gerty/request/event'
require 'honeybadger'
require_relative 'logger'
require_relative 'base'

module Processors 
  module Sqs
    extend self
   
    def process_sqs(aws_event:, service:, controller: nil, accept: [])
      Gerty::LOGGER.debug(aws_event)      
      handler = SqsRecordsHandler.new(accept, service, controller) 
      handler.handle_records(aws_event['Records'])
    end

    class SqsRecordsHandler
      include Processors::Base

      def initialize(accepts, service, controller)
        @accept_definition = accepts
        @service = service
        @controller_name = controller
      end

      def handle_records(aws_records)
        aws_records.each do |aws_record|
          begin
            handle_request sqs_record_bot_request(aws_record)
          rescue StandardError => e
            if ENV['HONEYBADGER_API_KEY']
              Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
            else
              raise e
            end
          end
        end
      end

      def accept?(bot_request)
        accepts.empty? || accepts.include?(bot_request.current['name'])
      end

      def accepts
        @accepts ||= begin
          @accept_definition.collect do |topic, events|
            events.collect do |event|
              require "request/events/#{topic}"
              Class.const_get("Gerty::Request::Events::#{topic.to_s.capitalize}::#{event.upcase}")
            end
          end.flatten
       end
      end
      
      def sqs_record_bot_request(aws_record)
        record = data(aws_record)
        event = JSON.parse(record["Message"])
        Gerty::Request::Request.new current: event['current'], trail: event['trail'], context: ::Gerty::Request::SlackContext.from_h(event['context'])
      end

    end
  end
end
