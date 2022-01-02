require 'aws-sdk-s3'

module Service
  module Kanbanize
    module Cron # change this name 
      extend self

      def listen
        [ 
          Gerty::Request::Events::Cron::Actions::FIND_ARCHIVE_TASK_IDS_FOR_BOARDS,
          Gerty::Request::Events::Cron::Actions::FIND_TASK_IDS_FOR_BOARDS,
          Gerty::Request::Events::Cron::Actions::KANBANIZE_IMPORT_ACTIVITIES,
          Gerty::Request::Events::Cron::Actions::COLUMN_STAY_INSIGHTS_BUILD_REQUESTED
        ]
      end

      def broadcast
        %w( cron )
      end

      Gerty::Service::BoundedContext.register(self)

      # just pass the request onto the cron queue
      def call(bot_request)
        bot_request.events << bot_request.current # ensures the message is passed on to the broadcast queue
      end
    end
  end
end