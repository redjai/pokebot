
require_relative 'simple_linear_regression'

module Service
  module Insight
    class ColumnStayInsights 

      attr_reader :board_id

      def initialize(team_board_id, stays, date_range)
        @date_range = date_range
        @team_board_id = team_board_id
        @stays = stays
      end

      def column_stays
        @columns_stays ||= begin
          columns = {}
          @stays[:items].each do |stay|
            columns[stay['column_stay']] ||= []
            columns[stay['column_stay']] << stay['duration']
          end
          columns
        end
      end
        
      def to_h
      {
        team_board_id: @team_board_id,
        columns: column_stays.collect do |column, durations| 
          { column: column, 
            percentile_75: durations.percentile(75).to_i, 
            percentile_85: durations.percentile(85).to_i, 
            percentile_95: durations.percentile(95).to_i,
              sample_size: durations.length } 
        end
      }
      end
    
    end
  end
end