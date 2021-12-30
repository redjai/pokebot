
require 'date'

module Storage
  module Models
    module Kanbanize
      class HistoryDetail

        def initialize(team_id:, kanbanize_data:)
          @kanbanize_data = kanbanize_data
          @team_id = team_id
        end

        def item
          @kanbanize_data.merge({'id' => id, 'entrydate' => entry_date})
        end

        def history_detail_id
          @kanbanize_data['historyid']
        end

        def id
          "#{@team_id}-#{@kanbanize_data['historyid']}"
        end

        def history_event
          @kanbanize_data['historyevent']
        end

        def details
          @kanbanize_data['details']
        end

        def entry_date
          DateTime.parse(@kanbanize_data['entrydate']).iso8601
        end

        def task_id
          @kanbanize_data['taskid']
        end
        
      end
    end
  end
end