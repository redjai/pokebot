module Service
  module Insight
    class NamedCycle
        
      attr_accessor :team_board_id, :name, :next_cycle_at, :from, :to 
      
      def initialize(team_board_id:, name:, next_cycle_at:, from:, to:)
        @team_board_id = team_board_id
        @name = name
        @next_cycle_at = next_cycle_at
        @from = from
        @to = to
      end

    end
  end
end