require_relative 'import_bucket'

module Storage
  module Kanbanize

    class HistoryDetail

       FROM_TO = Regexp.new("'([^']+)'")

       def initialize(data)
         @data = data
       end

       def moved?
        history_event == 'Task moved'  && details != "The task was reordered within the same board cell."
       end

       def created?
        self.history_event == 'Task created'
       end

       def archived?
        self.history_event == 'Task archived'
       end

       def id
        @data['historyid'].to_i
       end

       def event_type
         @data['eventtype']
       end

       def history_event
         @data['historyevent']
       end

       def task_id
         @data['taskid'].to_i
       end

       def details 
         @data['details']
       end

       def details_sql_safe
        @data['details'].gsub("'","`")
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
           raise "failed to parse from_to for task #{task_id} - #{details}" unless cols.first && cols.last
           { 
             from: cols.first.first, 
             to: cols.last.first 
           }
         end
       end

    end

    class TaskData

      def initialize(team_id:, board_id:, task_id: nil, task: nil)
        @team_id = team_id
        @board_id = board_id
        @task = task
        @task_id = task_id
      end

      def id
        @task_id || @task['taskid']
      end

      def key
        File.join("tasks", @team_id, @board_id, "#{id}.json")
      end

      def archive_key
        File.join("tasks", @team_id, @board_id, "archived", "#{id}.json")
      end

      def history_details
        @history_details ||= @task['historydetails'].collect do |history_detail|
          HistoryDetail.new(history_detail)
        end
      end

    end

    class TaskStore

      def initialize(team_id, board_id)
        @team_id = team_id
        @board_id = board_id
      end

      def store    
        @store ||= ImportBucket.new
      end

      def archive!(task)
        TaskData.new(team_id: @team_id, board_id: @board_id, task: task).tap do |data|
          delete(data.key)
          put(data.archive_key, task)
        end
      end

      def store!(task)
        TaskData.new(team_id: @team_id, board_id: @board_id, task: task).tap do |data|
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

      def initialize(team_id:, board_id:, archived:)
        @team_id = team_id
        @board_id = board_id
        @archived = archived
      end

      def fetch(task_id)
        data = TaskData.new(team_id: @team_id, board_id: @board_id, task_id: task_id)
        key = @archived ? data.archive_key : data.key
        object = store.bucket.object(key)

        if object.exists? # sometimes this returns false when object exists - not sure why yet.
          JSON.parse(object.get.body.read) 
        else
          Gerty::LOGGER.info("cannot fetch task #{key} as exists? return false")
          nil
        end
      end

    end
  end
end