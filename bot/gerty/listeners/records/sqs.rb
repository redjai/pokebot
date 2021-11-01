require 'gerty/request/event'
require 'gerty/request/request'
require 'gerty/request/context'
require 'honeybadger'
require_relative 'aws_event_base'

module Gerty
  module Listeners
    module Records
      class Sqs < Listeners::Records::AwsEventBase
        
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
          Gerty::Request::Request.new( current: event['current'], 
                                        trail: event['trail'], 
                                      context: ::Gerty::Request::SlackContext.from_h(event['context']),
                                         user: event['user'] )
        end

      end
    end
  end
end