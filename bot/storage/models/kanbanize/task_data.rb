# Takes a kanbanize task and creates Movement classes.
#

require 'storage/models/movement'
require_relative 'history_detail'


module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        class TaskData

          def initialize(team_id:, kanbanize_data:)
            @kanbanize_data = kanbanize_data
            @team_id = team_id
          end

          def history_details
            @history_details ||= @kanbanize_data['historydetails'].collect{ |history_detail| HistoryDetail.new(team_id: @team_id, 
                                                                                                        kanbanize_data: history_detail) }
                                                                                 .sort_by{ |history_detail| history_detail.history_detail_id }
          end

          def movements
            @movements ||= begin
              _movements = []
              
              movement_history_details.each_with_index do |history_detail, index| 
                _movements << Movement.build_kanbanize( team_id: @team_id,
                                              board_id: board_id,
                                                 index: index + 1, # account for task created
                                        history_detail: history_detail )
              end

              _movements.unshift(created(_movements.first))

              _archived = archived(_movements.last, _movements.length)
              _movements << _archived if _archived

              _movements
            end                                                       
          end

          def created(first_movement)
            Movement.build_kanbanize_created(
                                               team_id: @team_id,
                                              board_id: board_id,
                                               to_name: first_movement.from_name, #
                                        history_detail: created_history_detail
                                            )
          end

          def archived(last_movement, index)
            if archived_history_detail 
              Movement.build_kanbanize_archived(
                                                 team_id: @team_id,
                                                board_id: board_id,
                                                   index: index,
                                               from_name: last_movement.to_name, #
                                          history_detail: archived_history_detail
                                              )
            end
          end

          def movement_history_details
            @movement_history_details ||= history_details.select do |history_detail|
              !history_detail.details.scan(Movement::FROM_TO).flatten.empty?
            end.sort_by{ |history_detail| history_detail.history_detail_id }
          end

          def created_history_detail
            history_details.find{ |history_detail| history_detail.history_event == 'Task created' }
          end

          def archived_history_detail
            history_details.find{ |history_detail| history_detail.history_event == 'Task archived' }
          end

          def id
            "#{@team_id}-#{@kanbanize_data['taskid']}"
          end

          def item
            @kanbanize_data.merge({id: id, team_id: @team_id})
          end

          def board_id
            @kanbanize_data['boardid']
          end

        end
      end
    end
  end
end