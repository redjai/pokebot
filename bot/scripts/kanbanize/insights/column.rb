class Column

  attr_reader :board, :flow_type, :children, :section, :parent_lcname, :position

  def initialize(board:, section:, lcname:, flow_type:, position:, parent_lcname: nil)
    @board = board
    @lcname = lcname.upcase
    @parent_lcname = parent_lcname.upcase if parent_lcname
    @flow_type = flow_type
    @position = position
    @section = section
  end

  def lcname
    @parent_lcname ? "#{@parent_lcname}.#{@lcname}" : @lcname
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
