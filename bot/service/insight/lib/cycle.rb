require 'descriptive_statistics'

module Service
  module Insight
    class Cycle
      
      attr_accessor :team_board_id, :name, :from, :to, :cycles
      
      def initialize(team_id:, board_id:, name:, from:, to:, after:, before:, percentile:)
        @name = name
        @team_id = team_id
        @board_id = board_id
        @from = from
        @to = to
        @after = after
        @before = before
        @percentile = percentile
      end

      def task_cycles
        @task_cycles ||= []
      end
 
      def item
        {
          'team_board_id_name' => "#{@team_id}-#{@board_id}-#{@name}",
          'name' => @name,
          'from' => @from,
          'to' => @to,
          'after' => @after.to_datetime.iso8601,
          'before' => @before.to_datetime.iso8601,
          'percentile' => @percentile
        }
      end
 
    end
  end
end