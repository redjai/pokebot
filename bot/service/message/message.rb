require 'request/events/messages'

module Service
  module Message
    extend self
    
    def listen
      %w( app_mention message )
    end

    def broadcast
      %w( messages )
    end
    
    BoundedContext.register(self)

    def call(bot_request)
      bot_request.events << ::Request::Events::Messages.received(source: self, text: text(bot_request)) 
    end

    def text(bot_request)
      bot_request.current['data']['event']['text'].gsub(/<[^>]+>/,"").strip
    end

  end
end
