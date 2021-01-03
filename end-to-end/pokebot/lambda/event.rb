module Pokebot
  module Lambda 
    module Event 
      extend self

      def from_slack_event(aws_event)
        { 'slack' => http_data(aws_event) }
      end

      def http_data(aws_event)
        data(aws_event)
      end

      def each_sqs_record_data(aws_event)
        aws_event['Records'].each do |aws_record|
          yield sqs_record_data(aws_record)
        end
      end

      def sqs_record_data(aws_record)
        JSON.parse(data(aws_record)["Message"])
      end

      private

      def data(aws_event)
        JSON.parse(body(aws_event))
      end

      def body(aws_event)
        if aws_event["isBase64Encoded"]
          require 'base64'
          Base64.decode64(aws_event['body'])
        else
          aws_event['body']
        end
      end
    end
  end
end
