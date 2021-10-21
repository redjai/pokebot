require 'gerty/request/events/messages'
require 'gerty/request/events/users' 

module Service
  module Intent
    module KanbanizeUsernameUpdateRequested
      extend self

      def listen
        [ Gerty::Request::Events::Messages::RECEIVED ]
      end

      def broadcast
        [ :users ]
      end

      Gerty::Service::BoundedContext.register(self)
      
      def call(bot_request)
        if bot_request.current['data']['text'] =~ /kanbanize user is (.+)$/
          bot_request.events << Gerty::Request::Events::Users.set_kanbanize_username_requested(source: self, kanbanize_username: $1)
        end
      end 

    end
  end
end
