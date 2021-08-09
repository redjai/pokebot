require_relative 'board'
require 'date'

class Boards

  def boards
    @boards ||= {}
  end

  def build!
    structure_files.each do |path|
      structure = JSON.parse(structure_file(path))
      path =~ /(\d+)\.json/
      id = $1
      boards[id] = Board.new(id)
      board = boards[id]
      structure["columns"].each do |column|
        board.add_structural_column(
          section: column['section'],
          position: column['position'],
          lcname: column['lcname'],
          flow_type: column['flowtype'],
          children: column['children']
        )
      end
    end
  end

  def structure_files
    Dir.glob("board_structures/*.json")
  end

  def structure_file(path)
    File.read(path)
  end

  def add_board_column_task_duration(board_id, column, task, duration)
    board(board_id).add_column_task_duration(column, task, duration)
  end

  def board(board_id)
    @boards[board_id] ||= Board.new(board_id)
  end

  def load_data(file)
    CSV.foreach(file,{:headers=>:first_row}) do |row|
      board = boards[row[0]]
      entry_at = row[3] == 'NULL' ? nil : DateTime.parse(row[3]) 
      exit_at = row[4] == 'NULL' ? nil : DateTime.parse(row[4]) 
      duration = (( DateTime.parse(row[4]).to_time - DateTime.parse(row[3]).to_time ) / 3600).round if row[3] != "NULL"  && row[4] != "NULL"
      board.add_column_task_duration(
        column: row[1], 
        task: row[2], 
        entry_at: entry_at , 
        exit_at: exit_at, 
        entry_history_event: row[5], 
        exit_history_event: row[6]
      )
    end
  end
 
end