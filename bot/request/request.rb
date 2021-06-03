module Request 
  class Request 
    
    attr_reader :current, :context

    def initialize(current:, context: ::Request::SlackContext.new, trail: [])
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
      all.find do |event|
        event['intent']
      end
    end

    def intent?
      !intent.nil?
    end

    def current=(event)
      raise "intent #{intent.name} already set for this request" if event.intent && intent?
      trail.unshift(@current.to_h)
      @current = event.to_h
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

    private

    def all
      [@current] + trail 
    end

  end
end
