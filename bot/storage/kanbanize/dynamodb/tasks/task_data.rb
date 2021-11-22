
require_relative 'movement'
require_relative 'history_detail'
require_relative 'stay'

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
            @movements ||= history_details.collect do |history_detail| 
              Movement.build( team_id: @team_id,
                             board_id: board_id,
                       history_detail: history_detail)
            end.compact.sort_by{ |movement| movement.history_detail.history_detail_id.to_i }                                                       
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

          def column_stays
            @store_column_stays ||= begin
              stays = {}
              movements.each do |movement|
                stays[movement.from_name] ||= ColumnStay.new
                stays[movement.to_name] ||= ColumnStay.new
                stays[movement.from_name].exit = movement
                stays[movement.to_name].entry = movement
              end
              stays
            end
          end
          
          def section_stays
            @store_section_stays ||= begin
              stays = {}
              movements.each do |movement|
                next unless movement.section_boundary?
                stays[movement.from_name] ||= SectionStay.new
                stays[movement.to_name] ||= SectionStay.new
                stays[movement.from_name].exit = movement
                stays[movement.to_name].entry = movement
              end
              stays
            end
          end   
        end
      end
    end
  end
end