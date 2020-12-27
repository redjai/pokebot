def http_event_data(aws_event)
  body(aws_event)
end

def sqs_record_data(aws_event)
  JSON.parse(body(aws_event)["Message"])
end

def body(aws_event)
  body_string = if aws_event["isBase64Encoded"]
    require 'base64'
    Base64.decode64(aws_event['body'])
  else
    aws_event['body']
  end

  JSON.parse(body_string)
end
