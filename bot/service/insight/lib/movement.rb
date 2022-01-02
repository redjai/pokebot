module Service
  module Insight
    class Movement

      def initialize(team_id:, board_id:, task_id:, movement_id:, index:, delta:, date:, from:, to:)
        @team_id = team_id
        @board_id = board_id
        @movement_id = movement_id
        @index = index
        @delta = delta
        @task_id = task_id
        @date = date
        @from = from.downcase
        @to = to.downcase
      end

      def id
        "#{@team_id}-#{@board_id}-#{@task_id}-#{@movement_id}"
      end

      def item
        {
            id: id,
            from: @from,
            to: @to,
            team_board_id_from: "#{@team_id}-#{@board_id}-#{@from_name}",
            team_board_id_to: "#{@team_id}-#{@board_id}-#{@to_name}",
            task_id: @task_id,
            index: @index,
            date: @date,
            delta: @delta
        }
      end  
    end
  end
end