module Bot
  module Aws
    module Event 
      extend self

      def http_data(aws_event)
        data(aws_event)
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
