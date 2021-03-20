require_relative '../event'
require_relative 'base'

module Topic 
  module Events
    module Slack
      extend self
      extend Topic::Events::Base

      def api_event(aws_event)
        slack_data = http_data(aws_event)

        user = {
          slack_id: slack_data['event']['user'], 
           channel: slack_data['event']['channel']
        }

        record = Topic::Event.new(name: 'slack-event-api-request',
                                    source: 'slack-event-api',
                                   version: 1.0,
                                      data: slack_data)   
        Topic::Request.new slack_user: user, current: record
      end

      def interaction_event(aws_event)
        record = Topic::Event.new(  name: 'slack-interaction-api-request',
                           source: 'slack-interaction-api',
                          version: 1.0,
                             data: payload_data(aws_event))
        user = {
          'slack_id' => record.record['data']['user']['id'], 
          'channel' => record.record['data']['container']['channel_id'],
          'message_ts' => record.record['data']['container']['message_ts'],
          'response_url' => record.record['data']['response_url']
        }   
        Topic::Request.new slack_user: user, current: record
      end
      
      def shortcut_event(aws_event)
        record = Topic::Event.new(  name: 'slack-shortcut-api-request',
                           source: 'slack-shortcut-api',
                          version: 1.0,
                             data: shortcut_data(aws_event))
        user = {
          'slack_id' => record.record['data']['user_id'].first, 
          'channel' => record.record['data']['channel_id'].first,
          'response_url' => record.record['data']['response_url'].first
        }   
        Topic::Request.new slack_user: user, current: record
      end

    end

  end
end
