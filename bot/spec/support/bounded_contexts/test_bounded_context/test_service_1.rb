
require 'service/bounded_context'

class TestService1

  def self.listen
    %w( test_event_1a test_event_1b )
  end

  def self.broadcast
    %w( test_topic_1a test_topic_1b )
  end

  Service::BoundedContext.register(self)
  
  def self.call(bot_request)
    event = Gerty::Request::Event.new(source: self, name: 'test-service-1-updated-event', version: 1.0, data: {})
    bot_request.events << event
  end
                         
end