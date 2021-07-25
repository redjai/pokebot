require_relative 'import_bucket'

module Storage
  module Kanbanize

    class HistoryDetail

      FROM_TO = Regexp.new("'([^']+)'")

       def initialize(data)
         @data = data
       end

       def id
        @data['historyid']
       end

       def event_type
         @data['eventype']
       end

       def history_event
         @data['historyevent']
       end

       def task_id
         @data['taskid']
       end

       def details 
         @data['details']
       end

       def author
         @data['author']
       end

       def timestamp
         DateTime.parse(@data['entrydate']).to_time
       end

       def [](key)
         from_to[key]
       end

       def from_to
         @from_to ||= begin
           cols = details.scan(FROM_TO)
           raise "failed to parse from_to for #{details}" unless cols.first && cols.last
           { 
             from: cols.first.first, 
             to: cols.last.first 
           }
         end
       end

    end

    class TaskData

      def initialize(client_id:, board_id:, task_id: nil, task: nil)
        @client_id = client_id
        @board_id = board_id
        @task = task
        @task_id = task_id
      end

      def id
        @task_id || @task['taskid']
      end

      def key
        File.join("tasks", @client_id, @board_id, "#{id}.json")
      end

      def archive_key
        File.join("tasks", @client_id, @board_id, "archived", "#{id}.json")
      end

      def history_details
        @history_details ||= @task['historydetails'].collect do |history_detail|
          HistoryDetail.new(history_detail)
        end
      end

    end

    class TaskStore

      def initialize(client_id, board_id)
        @client_id = client_id
        @board_id = board_id
      end

      def store    
        @store ||= ImportBucket.new
      end

      def archive!(task)
        TaskData.new(client_id: @client_id, board_id: @board_id, task: task).tap do |data|
          delete(data.key)
          put(data.archive_key, task)
        end
      end

      def store!(task)
        TaskData.new(client_id: @client_id, board_id: @board_id, task: task).tap do |data|
          put(data.key, task)
        end
      end

      def put(key, task)
        object = store.bucket.object(key) 
        object.put(body: task.to_json)
      end

      def delete(key)
        object = store.bucket.object(key)
        object.delete if object.exists?
      end

    end

    class TaskFetcher

      def store
        @store ||= ImportBucket.new
      end

      def initialize(client_id:, board_id:)
        @client_id = client_id
        @board_id = board_id
      end

      def fetch(task_id)
        data = TaskData.new(client_id: @client_id, board_id: @board_id, task_id: task_id)
        object = store.bucket.object(data.key)
        JSON.parse(object.get.body.read)
      end

    end
  end
end