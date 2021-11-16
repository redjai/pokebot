require_relative 'board_structures'

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