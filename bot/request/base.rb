module Request 
  module Base

    def http_data(aws_event)
      data(aws_event)
    end

    def payload_data(aws_event)
      json = unescape(body(aws_event)).gsub(/^payload=/,"")
      JSON.parse(json)
    end

    def command_data(aws_event)
      body = unescape(body(aws_event))
      CGI.parse(body)
    end

    def unescape(body)
      require 'uri'
      CGI.unescape(body)
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
