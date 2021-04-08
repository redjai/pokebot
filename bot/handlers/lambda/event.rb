require 'topic/event'
require 'honeybadger'

module Lambda 
  module Event 
    extend self
    
    def process_sqs(aws_event:, controller:, accept: [])
      puts accept
      aws_event['Records'].each do |aws_record|
        begin
          bot_request = sqs_record_bot_request(aws_record)
          puts "Record in:"
          puts bot_request.to_json
          accept?(bot_request, accept)
          accept?(bot_request, accept)
          accept?(bot_request, accept)
          if accept?(bot_request, accept)
            if block_given?
              require_controller(controller)
              yield bot_request
            else
              call(controller, bot_request)
            end 
          else
            puts "event #{bot_request.name} not accepted by this service. expected #{accept}"
          end
        rescue StandardError => e
          if ENV['HONEYBADGER_API_KEY']
            Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
          else
            raise e
          end
        end
      end
    end

    def accept?(bot_request, accepts)
      accept_array(accepts).tap do |array|
        array.empty? || array.include?(bot_request.current['name'])
      end
    end

    def accept_array(accepts)
      @accepts ||= begin
        accepts.collect do |name|
          parts = name.split("#")
          Class.const_get("Topic::#{parts.first.capitalize}::#{parts.last.upcase}")
        end
      end
    end

    def sqs_record_bot_request(aws_record)
      record = data(aws_record)
      event = JSON.parse(record["Message"])
      Topic::Request.new current: event['current'], trail: event['trail'], context: Topic::SlackContext.from_h(event['context'])
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
      if e.context.is_a?(Hash)
        e.context
      elsif e.context.respond_to?(:params)
        e.context.params 
      end
    end

    def require_controller(controller)
      require File.join("service", controller.to_s, 'controller')
    end

    def call(controller, bot_request)
      require_controller(controller)
      controller(controller).call(bot_request)
    end

    def controller(controller)
      Class.const_get("Service::#{controller.to_s.capitalize}::Controller")
    end
  end
end
