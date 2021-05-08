
require_relative 'func1' # change this name

module Service
  module Test
    module Controller
      extend self

      def call(bot_request)
        Service::Test::Func1.call(bot_request) # change this name
      end
    end
  end
end
