require_relative '../base'
require_relative '../event'

module Request
  module Events
    module Messages
      extend self
      extend ::Request::Base

      RECEIVED = 'message-received'
      
      def received(source:, text:)
        data = {
          'text' => text
        }
        ::Request::Event.new(source: source, name: ::Request::Events::Messages::RECEIVED, version: 1.0, data: data)      
      end
    end
  end
end
