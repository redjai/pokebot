module Topic
  class SlackContext
      
    attr_accessor :slack_id, :channel, :response_url, :message_ts, :trigger_id

    def initialize(slack_id:, channel:, response_url: nil, message_ts: nil, trigger_id: nil)
      @slack_id = slack_id
      @channel = channel
      @response_url = response_url
      @message_ts = message_ts
      @trigger_id = trigger_id
    end

    def self.from_slack_command(command)
      new(
        slack_id: command.record['data']['user_id'].first, 
        channel: command.record['data']['channel_id'].first,
        response_url: command.record['data']['response_url'].first
      )
    end

    def self.from_slack_event(api_event)
      new(
        slack_id: api_event.record['data']['event']['user'], 
        channel: api_event.record['data']['event']['channel']
      )
    end

    def self.from_slack_interaction(record)
      new(
        slack_id: record.record['data']['user']['id'], 
        channel: record.record['data']['container']['channel_id'],
        message_ts: record.record['data']['container']['message_ts'],
        response_url: record.record['data']['response_url'],
        trigger_id: record.record['data']['trigger_id']
      )
    end
    
    def self.from_h(record)
      new(
        slack_id: record['slack_id'],
        channel: record['channel'],
        message_ts: record['message_ts'],
        response_url: record['response_url'],
        trigger_id: record['trigger_id']
      )
    end

    def to_h
      {
        'slack_id' =>  @slack_id,
        'channel' => @channel,
        'message_ts' => @message_ts,
        'response_url' => @response_url,
        'trigger_id' => @trigger_id
      }
    end
  end
end 
