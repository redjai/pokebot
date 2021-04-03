require 'json'

module Topic

  class SlackContext
      
      attr_accessor :slack_id, :channel, :response_url, :messge_ts, :trigger_id

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

      def self.from_slack_event(slack_data)
        new(
          slack_id: slack_data['event']['user'], 
          channel: slack_data['event']['channel']
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
        @slack_id = record['slack_id']
        @channel_id = record['channel_id']
        @message_ts = record['message_ts']
        @response_url = record['response_url']
        @trigger_id = record['trigger_id']
      end

      def to_h
        {
          slack_id: @slack_id,
          channel_id: @channel_id,
          message_ts: @message_ts,
          response_url: @response_url,
          trigger_id: @trigger_id
        }
      end
  end 
  
  class Event
    
    attr_reader :record

    def initialize(source:, name:, version:, data: [])
      @record = { 
                  'name' => name, 
                  'metadata' => 
                     { 
                       'source' => source, 
                       'version' => version, 
                       'ts' => Time.now.to_f 
                     },
                     'data' => data 
                 }
    end

    def to_h
      @record.to_h
    end

  end

  class Request 
    
    attr_reader :current, :context

    def initialize(context:, current:, trail: [])
      @context = context
      @current = current.to_h
      @trail = trail
    end

    def data
      current['data']
    end

    def name
      current['name']
    end

    def intent
      raise "intent has not been set for this request" unless @intent
      @intent
    end

    def intent=(record)
      raise "intent has already been set in this request" if @intent
      @intent = record
      self.current = record
    end

    def current=(record)
      trail.unshift(@current.to_h)
      @current = record.to_h
    end

    def trail
      @trail ||= []
    end
    
    def to_json
      to_h.to_json 
    end

    def to_h
      { current: @current, trail: @trail, context: @context.to_h }
    end
  end
end

