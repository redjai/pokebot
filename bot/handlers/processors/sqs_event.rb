require 'request/event'
require 'honeybadger'
require_relative 'logger'
require_relative 'event_base'

module Handlers 
  class SqsEvent < Processors::EventBase
    
      def initialize(aws_event)
        @aws_event = aws_event
      end

      def event_source_arn
        @arn ||= @aws_event["Records"].first["eventSourceARN"]
      end

     

      def bot_requests
        aws_records.collect do |aws_record|
          bot_request(aws_record) 
        end
      end

      private

      def aws_records
        @aws_event["Records"]
      end

      def bot_request(aws_record)
        record = data(aws_record)
        event = JSON.parse(record["Message"])
        ::Request::Request.new current: event['current'], trail: event['trail'], context: ::Request::SlackContext.from_h(event['context'])
      end

    
  end
end
