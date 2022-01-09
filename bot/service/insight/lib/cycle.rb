require 'descriptive_statistics'

module Service
  module Insight
    class Cycle
      
      attr_accessor :team_board_id, :name, :entry, :exit, :cycles
      
      def initialize(team_id:, board_id:, name:, entry:, exit:, after:, before:, percentile:, movements:)
        @name = name
        @team_id = team_id
        @board_id = board_id
        @entry = entry
        @exit = exit
        @after = after
        @before = before
        @percentile = percentile
        @movements = movements
      end

      def task_cycles
        @task_cycles ||= []
      end
 
      def item
        {
          'team_board_id_name' => "#{@team_id}-#{@board_id}-#{@name}",
          'name' => @name,
          'entry' => @entry,
          'exit' => @exit,
          'after' => @after.to_datetime.iso8601,
          'before' => @before.to_datetime.iso8601,
          'percentile' => @percentile,
          'movements' => @movements
        }
      end
 
    end
  end
end