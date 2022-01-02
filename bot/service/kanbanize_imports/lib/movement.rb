require_relative 'board_structures'

module Service
  module Kanbanize
    class Movement

      attr_accessor :team_id, :board_id, :from_name, :to_name

      FROM_TO = Regexp.new("^From\s'([^']+)'\sto\s'([^']+)'$")

      def self.build_kanbanize(team_id:, board_id:, index:, history_detail:)
        cols = history_detail.details.scan(FROM_TO).flatten
        raise "not a movement history detail" if cols.empty?
        raise "unexpected index #{0}" if index < 1
        new(
              team_id: team_id, 
              board_id: board_id, 
              task_id: history_detail.task_id,
          movement_id: history_detail.history_detail_id,
                 date: history_detail.entry_date,
                index: index, 
            from_name: cols.first, 
              to_name: cols.last
        )
      end

      def self.build_kanbanize_created(team_id:, board_id:, to_name:, history_detail:)
        new(
              team_id: team_id, 
              board_id: board_id, 
              task_id: history_detail.task_id,
          movement_id: history_detail.history_detail_id,
                  date: history_detail.entry_date,
                index: 0, 
            from_name: "NULL_CREATED", 
              to_name: to_name
        )
      end

      def self.build_kanbanize_archived(team_id:, board_id:, index: , from_name:, history_detail:)
        new(
              team_id: team_id, 
              board_id: board_id, 
              task_id: history_detail.task_id,
          movement_id: history_detail.history_detail_id,
                  date: history_detail.entry_date,
                index: index, 
            from_name: from_name, 
              to_name: "NULL_ARCHIVED"
        )
      end

      def initialize(team_id:, board_id:, task_id:, movement_id:, index:, date:, from_name:, to_name:)
        @team_id = team_id
        @board_id = board_id
        @movement_id = movement_id
        @index = index
        @task_id = task_id
        @date = date
        @from_name = from_name.downcase
        @to_name = to_name.downcase
      end

      def to_h
        {
            team_id: @team_id,
            board_id: @board_id,
            task_id: @task_id,
            movement_id: @movement_id,
            from: @from_name,
            to: @to_name,
            index: @index,
            delta: @delta, 
            date: @date
        }
      end  

      private

      def delta
        posa = board_structure.column_index(from_name)
        posb = board_structure.column_index(to_name)
        posb - posa if posa && posb
      end

      def board_structure
        BoardStructures.board(@team_id, @board_id)
      end
      
    end
  end
end