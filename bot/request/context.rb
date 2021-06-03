require 'json'
module Request 
  class SlackContext
      
    attr_accessor :slack_id, :channel, :response_url, :message_ts, :trigger_id

    def initialize(slack_id: nil, channel: nil, response_url: nil, message_ts: nil, trigger_id: nil, private_metadata: nil)
      @slack_id = slack_id
      @channel = channel
      @response_url = response_url
      @message_ts = message_ts
      @trigger_id = trigger_id
      @private_metadata = private_metadata
    end

    def private_metadata
      JSON.parse(@private_metadata)
    end

    def self.from_slack_command(command)
      _from_slack_command(
        slack_id: command.record['data']['user_id'].first, 
        channel: command.record['data']['channel_id'].first,
        response_url: command.record['data']['response_url'].first
      )
    end
    
    def self._from_slack_command(slack_id:, channel:, response_url:)
      new(
        slack_id: slack_id, 
        channel: channel,
        response_url: response_url
      )
    end

    def self.from_slack_event(api_event)
      return nil unless api_event.record['data']['event'] # challenge events have no event record
      new(
        slack_id: api_event.record['data']['event']['user'], 
        channel: api_event.record['data']['event']['channel']
      )
    end
    
    def self._from_slack_event(slack_id:, channel:)
      new(
        slack_id: slack_id, 
        channel: channel
      )
    end

    def self.from_slack_interaction(record)
      case record.record['data']['type']
      when 'block_actions'
        from_slack_block_actions_interaction(record)
      when 'view_submission'
        from_slack_view_submission_interaction(record)
      end
    end

    def self.from_slack_block_actions_interaction(record)
      _from_slack_block_actions_interaction(
        slack_id: record.record['data']['user']['id'], 
        channel: record.record['data']['container']['channel_id'],
        message_ts: record.record['data']['container']['message_ts'],
        response_url: record.record['data']['response_url'],
        trigger_id: record.record['data']['trigger_id']
      )
    end
    
    def self._from_slack_block_actions_interaction(slack_id:, channel:, message_ts:, response_url:, trigger_id:)
      new(
        slack_id: slack_id, 
        channel: channel,
        message_ts: message_ts,
        response_url: response_url,
        trigger_id: trigger_id
      )
    end

    def self.from_slack_view_submission_interaction(record)
      _from_slack_view_submission_interaction(
        slack_id: record.record['data']['user']['id'], 
        trigger_id: record.record['data']['trigger_id'],
        response_url: record.record['data']['response_url'],
        private_metadata: record.record['data']['view']['private_metadata']
      )
    end
    
    def self._from_slack_view_submission_interaction(slack_id:, response_url:, trigger_id:, private_metadata:)
      new(
        slack_id: slack_id, 
        response_url: response_url,
        trigger_id: trigger_id,
        private_metadata: private_metadata
      )
    end
    
    def self.from_h(record)
      new(
        slack_id: record['slack_id'],
        channel: record['channel'],
        message_ts: record['message_ts'],
        response_url: record['response_url'],
        trigger_id: record['trigger_id'],
        private_metadata: record['private_metadata']
      )
    end

    def to_h
      {
        'slack_id' =>  @slack_id,
        'channel' => @channel,
        'message_ts' => @message_ts,
        'response_url' => @response_url,
        'trigger_id' => @trigger_id,
        'private_metadata' => @private_metadata
      }
    end
  end
end 
