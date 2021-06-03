def handler(service)
%{
require 'handlers/lambda/event'
require 'request/events/topic'

module #{service.capitalize}  
  class Handler
    def self.handle(event:, context:)
      puts event
      Lambda::Event.process_sqs(aws_event: event, controller: :#{service}, accept: {
        # topic: %w{ event1 event2 },
      })
    end
  end
end
}
end

def controller(service)
%{
require_relative 'func1' # change this name

module Service
  module #{service.capitalize}
    module Controller
      extend self

      def call(bot_request)
        Service::#{service.capitalize}::Func1.call(bot_request) # change this name
      end
    end
  end
end
}
end

def func1(service)
%{
module Service
  module #{service.capitalize}
    module Func1 # change this name 
      extend self

      def call(bot_request)
        # business logic goes here...
      end
    end
  end
end
}
end

def spec(service)
%{
require 'handlers/#{service}'
require 'request/events/topic'

describe #{service.capitalize}::Handler do

  let(:aws_event){ }
  let(:context){ }

  it 'should' do
    #{service.capitalize}::Handler.handle(event: aws_event, context: context)
  end

end
}
end
