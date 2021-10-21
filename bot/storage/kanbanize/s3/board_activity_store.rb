require_relative 'import_bucket'
require_relative 'activity_data'

module Storage
  module Kanbanize

    class BoardActivityStore

      attr_accessor :data

      def initialize(client_id, board_id)
        @client_id = client_id
        @board_id = board_id
      end

      def store!(activity)
        data = BoardActivityData.new(@client_id, @board_id, activity)
        object = store.bucket.object(data.key)
        if store.bucket.object(data.key).exists?
          false
        else
          object.put(body: data.to_json)
          true
        end
      end

      def store
        @store ||= ImportBucket.new
      end
      
    end
  end
end