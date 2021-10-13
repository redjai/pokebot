require_relative 'board'
require 'date'
require 'json'

class BoardStructure

  def initialize(structure_files="data/boards/*.json")
    @structure_files = structure_files
  end

  def boards
    @boards ||= {}
  end

  def build!
    structure_files.each do |path|
      board_data = JSON.parse(structure_file(path))
      path =~ /(\d+)\.json/
      id = $1
      boards[id] = build_board(id, board_data)  
    end
  end

  def build_board(id, board_data)
    board = Board.new(id)
    board_data["columns"].each do |column_data|
      column = build_column(board, column_data)
      board.columns << column
    end
    board
  end

  def build_column(board, column_data, parent_column: nil)
    lcname = if parent_column
      "#{parent_column}.#{column_data['lcname']}"
    else
      column_data['lcname']
    end

    column = Column.new(
      board: board,
      section: column_data['section'],
      position: column_data['position'], 
      lcname: lcname, 
      flow_type: column_data['flowtype']
    )

    column_data.fetch('children',[]).each do |child_column_data|
      child = build_column(board, child_column_data, parent_column: column.lcname)
      column.children << child
    end

    column
  end



  def structure_files
    Dir.glob(@structure_files)
  end

  def structure_file(path)
    File.read(path)
  end

  def add_board_column_task_duration(board_id, column, task_id, duration)
    board(board_id).add_column_task_duration(column, task_id, duration)
  end

  def board(board_id)
    @boards[board_id] ||= Board.new(board_id)
  end

  def load_data(file)
    CSV.foreach(file,{headers: :first_row}) do |row|
      board = boards[row[0]]
      
      entry_at = row[3] == 'NULL' ? nil : DateTime.parse(row[3]) 
      exit_at = row[4] == 'NULL' ? nil : DateTime.parse(row[4]) 
         
      column = board.find_column(row[1].upcase)

      next unless column
      
      task_action = TaskAction.new(
        entry_at: entry_at, 
        exit_at: exit_at,
        entry_history_event: row[5],
        exit_history_event: row[6]
      )

      column.task_actions << task_action
      task = board.tasks.add(row[2])
      task.task_actions << task_action 
    end
  end
 
end