module Topic 
  module Events
    module Base

      def http_data(aws_event)
        data(aws_event)
      end

      def payload_data(aws_event)
        require 'uri'
        JSON.parse(CGI.unescape(body(aws_event).gsub(/^payload=/,"")))
      end

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
