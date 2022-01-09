module Service
  module Insight
    class Movement
        
      attr_accessor :task_id, :date, :from, :to

      def initialize(team_id:, board_id:, movement_id:, task_id:, index:, delta:, date:, from:, to:)
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

      def self.from_event(movement)
        new(
            team_id: movement['team_id'], 
           board_id: movement['board_id'],
            task_id: movement['task_id'],
        movement_id: movement['movement_id'],
              index: movement['index'],
              delta: movement['delta'],
               date: movement['date'],
               from: movement['from'],
                 to: movement['to']
        )      
      end

      def self.from_item(team_id:, board_id:, item:)
        new(
            team_id: team_id,
           board_id: board_id,
            task_id: item['task_id'],
        movement_id: item['id'],
              index: item['index'],
              delta: item['delta'],
               date: item['date'],
               from: item['from'],
                 to: item['to']
        )
      end

      def item
        {
            id: @movement_id,
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