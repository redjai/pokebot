module Service
  module Kanbanize
    module Jobber
      extend self
      extend Storage::Kanbanize::DynamoDB

      def call(bot_request)



      end

      def archive_tasks(bot_request)

        client = get_client(bot_request.data['client_id'])

        client.board_ids.each do |board_id|
          bot_request.events << Request::Events::
          Topic::Sns.broadcast()
        end

      end
    end
  end
end
