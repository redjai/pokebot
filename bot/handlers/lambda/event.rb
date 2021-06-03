require 'request/event'
require 'honeybadger'
require 'logger'
require_relative 'logger'

module Lambda 
  module Event 
    extend self
   
    def process_sqs(aws_event:, controller:, accept: [])
      Bot::LOGGER.debug(aws_event)      
      handler = SqsRecordsHandler.new(accept, controller) 
      handler.handle_records(aws_event['Records'])
    end

    class SqsRecordsHandler

      def initialize(accepts, controller)
        @accept_definition = accepts
        @controller_name = controller
      end

      def handle_records(aws_records)
        aws_records.each do |aws_record|
          begin
            handle_request sqs_record_bot_request(aws_record)
          rescue StandardError => e
            if ENV['HONEYBADGER_API_KEY']
              Honeybadger.notify(e, sync: true, context: context(e)) #sync true is important as we have no background worker thread
            else
              raise e
            end
          end
        end
      end

      def handle_request(bot_request)
        Bot::LOGGER.debug "Record in:"
        Bot::LOGGER.debug bot_request.to_json
        if accept?(bot_request)
          require_controller
          if block_given?
            yield bot_request
          else
            call(bot_request)
          end 
        else
          Bot::LOGGER.debug("event #{bot_request.name} not accepted by this service. expected #{accepts}")
        end
      end

      def require_controller
        require File.join("service", @controller_name.to_s, 'controller')
      end

      def call(bot_request)
        controller.call(bot_request)
      end

      def controller
        Class.const_get("Service::#{@controller_name.to_s.capitalize}::Controller")
      end

      def accept?(bot_request)
        accepts.empty? || accepts.include?(bot_request.current['name'])
      end

      def accepts
        @accepts ||= begin
          @accept_definition.collect do |topic, events|
            events.collect do |event|
              Class.const_get("::Request::Events::#{topic.to_s.capitalize}::#{event.upcase}")
            end
          end.flatten
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
      
      private
      
      def sqs_record_bot_request(aws_record)
        record = data(aws_record)
        event = JSON.parse(record["Message"])
        ::Request::Request.new current: event['current'], trail: event['trail'], context: ::Request::SlackContext.from_h(event['context'])
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
