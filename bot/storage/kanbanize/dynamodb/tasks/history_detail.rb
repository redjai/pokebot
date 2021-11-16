module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        class HistoryDetail

          def initialize(team_id:, kanbanize_data:)
            @kanbanize_data = kanbanize_data
            @team_id = team_id
          end

          def item
            @kanbanize_data.merge({'id' => id, 'entrydate' => entrydate})
          end

          def history_detail_id
            @kanbanize_data['historyid']
          end

          def id
            "#{@team_id}-#{@kanbanize_data['historyid']}"
          end

          def details
            @kanbanize_data['details']
          end

          def entrydate
            DateTime.parse(@kanbanize_data['entrydate']).iso8601
          end

          def task_id
            @kanbanize_data['taskid']
          end
          
        end
      end
    end
  end
end