require_relative 'import_bucket'

module Storage
  module Kanbanize
  
    class ActivityData

      attr_reader :data

      def initialize(client_id, board_id, activity)
        @client_id = client_id
        @board_id = board_id
        @data = activity
      end

      def to_json
        data.to_json
      end

      def date
        @date ||= Date.parse(data['date'])
      end

      def year
        date.year
      end

      def month
        date.month
      end

      def day
        date.mday
      end

      def task_id
        data['taskid']
      end

      def key
        File.join("imports", "activities", year.to_s, month.to_s, day.to_s, @client_id, @board_id, task_id, file)
      end

      def file
        "#{data["date"].gsub(/\s/,"__").gsub(/:/,"-")}.json"     
      end

    end

    class ActivityStore

      attr_accessor :data

      def initialize(client_id, board_id)
        @client_id = client_id
        @board_id = board_id
      end

      def store!(activity)
        data = ActivityData.new(@client_id, @board_id, activity)
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