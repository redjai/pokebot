
require 'service/bounded_context'

class TestService2

  def self.listen
    %w( test_event_2a test_event_2b )
  end

  def self.broadcast
    %w( test_topic_2a test_topic_2b )
  end

  Service::BoundedContext.register(self)

  def self.call(bot_request)
    event = ::Request::Event.new(source: self, name: 'test-service-2-updated-event', version: 1.0, data: {})
    bot_request.events << event
    bot_request
  end

end