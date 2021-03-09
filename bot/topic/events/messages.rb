require_relative '../event'
require_relative 'base'

module Topic 
  module Events
    module Messages
      extend self
      extend Topic::Events::Base
      
      def received(source:, text:)
        data = {
          'text' => text
        }
        Topic::Event.new(source: source, name: MESSAGE_RECEIVED, version: 1.0, data: data)      
      end

    end
  end
end
