
require 'json'

module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        module BoardStructures
          extend self

          @@boards = {}

          @@board_root = 

          def board(team_id, board_id)
            @@boards[team_id] ||= {}
            @@boards[team_id][board_id] ||= load_board(team_id, board_id)
            @@boards[team_id][board_id]
          end

          def board_root
            ENV['BOARD_ROOT'] || File.join("data","boards")
          end

          def board_file(team_id, board_id)
            puts self.inspect
            File.join(board_root,team_id,"#{board_id}.json")
          end

          private

          def load_board(team_id, board_id)
            file = board_file(team_id, board_id)
            board_data = File.open(file).read
            BoardStructure.new(JSON.parse(board_data))
          end

        end

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
end



