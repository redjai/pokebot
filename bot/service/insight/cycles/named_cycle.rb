module Service
  module Insight
    module Cycles
      class NamedCycle
        
        attr_accessor :team_board_id, :name, :entry_column_name, :exit_column_name 
        
        def initialize(name:, board_id:, entry_column_name:, exit_column_name:)
          @name = name
          @team_board_id = team_board_id
          @entry_column_name = entry_column_name
          @exit_column_name = exit_column_name
        end

        def to_h
          {
            'name' => @name,
            'team_board_id' => @team_board_id,
            'entry_column_name' => @entry_column_name,
            'exit_column_name' => @exit_column_name
          }
        end

        def self.from_h(data)
          new(         
                          name: data['name'], 
                  team_board_id: data['team_board_id'],
              entry_column_name: data['entry_coulmn_name'],
              exit_column_name: data['exit_column_name']
          )
        end
      end
    end
  end
end
