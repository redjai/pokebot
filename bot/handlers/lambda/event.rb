require 'topic/event'
require 'honeybadger'

module Lambda 
  module Event 
    extend self
    
    def each_sqs_record_bot_request(aws_event:, accept: [])
      aws_event['Records'].each do |aws_record|
        begin
          bot_request = sqs_record_bot_request(aws_record)
          puts "Record in:"
          puts bot_request.to_json
          if accept.empty? || accept.include?(bot_request.current['name'])
            yield bot_request
          else
            puts "event #{bot_request.name} not accepted by this service. expected #{accept}"
          end
        rescue StandardError => e
          Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
        end
      end
    end

    def sqs_record_bot_request(aws_record)
      record = data(aws_record)
      event = JSON.parse(record["Message"])
      Topic::Request.new slack_user: event['slack_user'], current: event['current'], trail: event['trail']
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

    def context(e)
      return nil unless e.respond_to?(:context)
      case e.context
      when Seahorse::Client::RequestContext
        e.context.params
      else
        e.context
      end
    end
  end
end
