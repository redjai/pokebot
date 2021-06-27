require 'net/http'
require_relative 'api'

module Service
  module Kanbanize
    module GetAllTasks # change this name 
      extend self
      extend Service::Kanbanize::Api

      def call(bot_request)
        tasks(board_id: bot_request.data['boardid'])         
      end

      def tasks(board_id:) 
        body = body(board_id: board_id)
        uri = uri(function: :get_all_tasks)
        post(uri: uri, body: body) 
      end

      def body(board_id:)
        { boardid: board_id }
      end

    end
  end
end
