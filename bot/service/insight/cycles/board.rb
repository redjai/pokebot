
module Service
  module Insight
    module Cycles
      class Board

        def initialize(team_board_id:, named_cycle:)

        end

        def grouped_by_task
          @grouped_by_task ||= @movements.group_by{ |movement| movement.task_id }
        end
        
        def cycle(start_date:, finish_date:)
          @cycle = Cycle.new()
          grouped_by_task.each do |task_id, movements|
            entry_movement = movements(start).find{|movement| movement.entry_column_name == named_cycle.entry_column_name }
            exit_movement = movements.find{|movement| movement.exit_column_name == named_cycle.exit_column_name }
            @cycle.durations << exit_movement_date - entry_movement.date if entry_movement && exit_movement
          end
        end

      end
    end
  end
end