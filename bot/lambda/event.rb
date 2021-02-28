require 'bot/event'

module Lambda 
  module Event 
    extend self
    
    
    def each_sqs_record_bot_event(aws_event:, accept: [])
      aws_event['Records'].each do |aws_record|
        bot_event = sqs_record_bot_event(aws_record)
        puts "Record in:"
        puts bot_event.to_json
        if accept.empty? || accept.include?(bot_event.current['name'])
          yield bot_event
        else
          puts "event #{bot_event['name']} not accepted"
        end
      end
    end

    def sqs_record_bot_event(aws_record)
      event = JSON.parse(data(aws_record)["Message"])
      Bot::Event.new user: event['user'], current: event['current'], trail: event['trail']
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
