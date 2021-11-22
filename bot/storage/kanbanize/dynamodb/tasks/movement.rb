require_relative 'board_structures'

# 

module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        class Movement

          attr_accessor :team_id, :board_id, :history_detail

          FROM_TO = Regexp.new("^From\s'([^']+)'\sto\s'([^']+)'$")

          def self.build(team_id:, board_id:, history_detail:)
            unless history_detail.details.scan(FROM_TO).flatten.empty?
              new(team_id: team_id, board_id: board_id, history_detail: history_detail)
            end
          end

          def id
            "#{team_id}-#{history_detail.task_id}-#{history_detail.history_detail_id}"
          end

          def from_name
            @from_name ||= cols.first.downcase if cols.first
          end

          def to_name
            @to_name ||= cols.last.downcase if cols.last
          end

          def from_section_name
            board_structure.section(from_name)
          end

          def to_section_name
            board_structure.section(to_name)
          end

          def section_valid?
            !from_section_name.nil? && !to_section_name.nil?
          end

          def section_boundary?
            section_valid? && from_section_name != to_section_name
          end

          def delta
            posa = board_structure.column_index(from_name)
            posb = board_structure.column_index(to_name)
            board_structure.columns.collect{|column| column.name }.slice(posa..posb) if posa && posb
          end

          def item
            {
               id: id,
               from: from_name,
               to: to_name,
               team_board_id: "#{@team_id}-#{@board_id}",
               task_id: history_detail.task_id,
               entry_date: history_detail.entry_date,
               from_section_name: from_section_name,
               to_section_name: to_section_name,
               delta: delta
            }
          end

          private

          def cols
            history_detail.details.scan(FROM_TO).flatten
          end

          def board_structure
            BoardStructures.board(@team_id, @board_id)
          end

          def initialize(team_id:, board_id:, history_detail:)
            @team_id = team_id
            @board_id = board_id
            @history_detail = history_detail
          end

        end
      end
    end
  end
end