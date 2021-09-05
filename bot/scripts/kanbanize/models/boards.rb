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
      structure["columns"].each do |scolumn|
        section = board.find_section(scolumn['section'])
        column = Column.new(
          position: scolumn['position'], 
          lcname: scolumn['lcname'].upcase, 
          flow_type: scolumn['flow_type']
        )
        scolumn.fetch('children',[]).each do |child|
          column.children[child['lcname'].upcase] = Column.new(
            position: child['position'], 
            lcname: child['lcname'].upcase, 
            flow_type: child['flowtype']
          )
        end
        section.columns[scolumn['lcname'].upcase] = column
      end
    end
  end



  def structure_files
    Dir.glob("board_structures/*.json")
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