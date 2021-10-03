class Wait

  attr_reader :board, :column_name, :entry_at, :exit_at, :type

  def initialize(board:, column_name:, entry_at:, exit_at:, type: :wait)
    @board = board
    @column_name = column_name
    @entry_at = entry_at
    @exit_at = exit_at
    @type = type
  end

  def current?
    !board.edges.index{ |edge| from == edge.lcname }
  end

  def length
    (exit_at - entry_at)
  end

  def group_by_column_name
    group_by{ |wait| wait.column_name }
  end

end
