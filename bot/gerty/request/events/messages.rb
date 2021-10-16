require_relative '../base'
require_relative '../event'

module Gerty
  module Request
    module Events
      module Messages
        extend self
        extend Gerty::Request::Base

        RECEIVED = 'message-received'
        
        def received(source:, text:)
          data = {
            'text' => text
          }
          Gerty::Request::Event.new(source: source, name: Gerty::Request::Events::Messages::RECEIVED, version: 1.0, data: data)      
        end
      end
    end
  end
end
