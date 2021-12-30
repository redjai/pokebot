
require 'json'
require_relative 'board_structure'

module Storage
  module Models
    module Kanbanize
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
          File.join(board_root,team_id,"#{board_id}.json")
        end

        private

        def load_board(team_id, board_id)
          file = board_file(team_id, board_id)
          board_data = File.open(file).read
          BoardStructure.new(JSON.parse(board_data))
        end

      end

    end
  end
end



