require_relative 'import_bucket'
require_relative 'activity_data'

module Storage
  module Kanbanize

    class AuthorActivityStore

      attr_accessor :data

      def initialize(team_idboard_id)
        @team_id teteam_id
        @board_id = board_id
      end

      def store!(activity)
        data = AuthorActivityData.new(@team_id@board_id, activity)
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