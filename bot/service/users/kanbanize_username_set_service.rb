require 'storage/kanbanize/dynamodb/user'
require 'gerty/request/events/users'
require 'gerty/service/bounded_context'

module Service
  module User
    module KanbanizeUsername 
    extend self

      def listen
        [ Gerty::Request::Events::Users::USER_KANBANIZE_USERNAME_UPDATE_REQUESTED ]
      end

      def broadcast
        [ :users ]
      end

      Gerty::Service::BoundedContext.register(self)

      def call(bot_request)
        updates = ::Storage::Kanbanize::DynamoDB::User.set_kanbanize_username(
                                                                             team_id: bot_request.context.team_id, 
                                                                            slack_id: bot_request.context.slack_id, 
                                                                  kanbanize_username: bot_request.data['kanbanize_username'] )
        if updates
          bot_request.events << Gerty::Request::Events::Users.kanbanize_username_updated( source: :user, 
                                                                              kanbanize_username: bot_request.data['kanbanize_username'] )
        end
      end
    end
  end
end
