require_relative '../base'
require_relative '../event'

module Request
  module Events
    module Slack
      extend self
      extend ::Request::Base
      
      EVENT_API_REQUEST = 'slack-event-api-request'
      INTERACTION_API_REQUEST = 'slack-interaction-api-request'
      SHORTCUT_API_REQUEST = 'slack-command-api-request'
      
      def api_request(aws_event)
        event = api_event(aws_event)
        ::Request::Request.new current: event, context: ::Request::SlackContext.from_slack_event(event)
      end

      def api_event(aws_event)
        ::Request::Event.new(name: ::Request::Events::Slack::EVENT_API_REQUEST,
                       source: 'slack-event-api',
                      version: 1.0,
                         data: http_data(aws_event))   
      end

      def interaction_request(aws_event)
        event = interaction_event(aws_event)
        ::Request::Request.new current: event, context: ::Request::SlackContext.from_slack_interaction(event)
      end

      def interaction_event(aws_event)
        ::Request::Event.new(name: ::Request::Events::Slack::INTERACTION_API_REQUEST,
                       source: 'slack-interaction-api',
                      version: 1.0,
                         data: payload_data(aws_event))
      end
      
      def command_request(aws_event)
        event = command_event(aws_event)
        ::Request::Request.new current: event, 
                           context: ::Request::SlackContext.from_slack_command(event)
      end

      def command_event(aws_event)
        ::Request::Event.new(  name: ::Request::Events::Slack::SHORTCUT_API_REQUEST,
                         source: 'slack-command-api',
                        version: 1.0,
                           data: command_data(aws_event))
      end
    end
  end
end
