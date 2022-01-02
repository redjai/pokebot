module Storage
  module Models
    class Movement

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

      def id
        "#{@team_id}-#{@board_id}-#{@task_id}-#{@movement_id}"
      end

      def delta
        posa = board_structure.column_index(from_name)
        posb = board_structure.column_index(to_name)
        posb - posa if posa && posb
      end

      def item
        {
            id: id,
            from: from_name,
            to: to_name,
            team_board_id_from: "#{@team_id}-#{@board_id}-#{@from_name}",
            team_board_id_to: "#{@team_id}-#{@board_id}-#{@to_name}",
            task_id: @task_id,
            index: @index,
            date: @date,
            delta: delta
        }
      end  
    end
  end
end