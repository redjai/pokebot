module Storage
  module Models
    module Kanbanize
      class BoardStructure

        def initialize(board_structure)
          @board_structure = board_structure
        end

        def columns 
          @columns ||= unpack
        end

        def section(column_name)
          column_name.downcase!
          found = columns.find do |column|
            column.name.downcase == column_name.downcase
          end
          found.section if found
        end

        def column_index(column_name)
          columns.index{|column| column_name == column.name }
        end

        private 

        def unpack
          @board_structure['columns'].collect do |column|
            if column['children']
              column['children'].collect do |child_column|
                Column.new(kanbanize_data: child_column, parent_kanbanize_data: column)
              end
            else
              Column.new(kanbanize_data: column)
            end
          end.flatten
        end
      end

      class Column
        
        def initialize(kanbanize_data:, parent_kanbanize_data: nil)
          @kanbanize_data = kanbanize_data
          @parent_kanbanize_data = parent_kanbanize_data
        end

        def name
          if @parent_kanbanize_data
            "#{@parent_kanbanize_data['lcname']}.#{@kanbanize_data['lcname']}".downcase
          else
            @kanbanize_data['lcname'].downcase
          end
        end

        def section
          @kanbanize_data['section']
        end

      end
    end
  end
end
