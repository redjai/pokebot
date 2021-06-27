require 'request/event'
require 'honeybadger'
require 'logger'
require_relative 'logger'

module Processors 
  module Base

    def handle_request(bot_request)
      Bot::LOGGER.debug "Record in:"
      Bot::LOGGER.debug bot_request.to_json
      if accept?(bot_request)
        call(bot_request)
      else
        Bot::LOGGER.debug("event #{bot_request.name} not accepted by this service. expected #{accepts}")
      end
    end

    def require_controller
      require File.join("service", @controller_name.to_s, 'controller')
    end

    def call(bot_request)
      require_controller
      controller.call(bot_request)
    end

    def controller
      Class.const_get("Service::#{@controller_name.to_s.capitalize}::Controller")
    end
    
    def context(e)
      return nil unless e.respond_to?(:context)
      if e.context.is_a?(Hash)
        e.context
      elsif e.context.respond_to?(:params)
        e.context.params 
      end
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
