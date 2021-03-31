require 'json'

module Topic 
  
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
    
    attr_reader :current, :slack_user

    def initialize(slack_user:, current:, trail: [])
      @slack_user = slack_user
      @current = current.to_h
      @trail = trail
    end

    def data
      current['data']
    end

    def name
      current['name']
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
      { current: @current, trail: @trail, slack_user: @slack_user }
    end
  end
end

