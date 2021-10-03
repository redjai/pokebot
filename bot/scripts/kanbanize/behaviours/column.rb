class Column

  attr_reader :board, :position, :lcname, :flow_type, :children, :section

  def initialize(board:, section:, position:, lcname:, flow_type:, children:[])
    @board = board
    @position = position
    @lcname = lcname.upcase
    @flow_type = flow_type
    @section = section
  end

  def queue?
    @flow_type == "queue"
  end

  def children
    @children ||= []
  end

  def children?
    !children.empty?
  end

end
