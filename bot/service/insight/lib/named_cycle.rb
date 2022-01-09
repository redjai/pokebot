module Service
  module Insight
    class NamedCycle
        
      attr_accessor :team_board_id, :name, :next_cycle_at, :entry, :exit 
      
      def initialize(team_board_id:, name:, next_cycle_at:, entry:, exit:)
        @team_board_id = team_board_id
        @name = name
        @next_cycle_at = next_cycle_at
        @entry = entry
        @exit = exit
      end

    end
  end
end