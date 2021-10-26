class Columns < Array

  def column(column_name)
    find{|col| col.lcname == column_name}
  end

  def exists?(column_name)
    !column(name).nil?
  end

  def delta(column_a_name, column_b_name)
    edge_a = column(column_a_name)
    edge_b = column(column_b_name)
    index(edge_b) - index(edge_a) if edge_a && edge_b
  end

  def queues
    @queues ||= begin
      queues = []
      columns.each do |column|
        if column.children?
          column.children.each do |child|
            queues << child if child.queue?
          end
        else
          queues << column if column.queue?
        end 
      end
      queues
    end
  end
end

class ColumnRange

  attr_accessor :from_index, :to_index

  def initialize(from_index:, to_index:, columns:)
    @from_index = from_index
    @to_index = to_index
    @columns = columns
  end

  def from
    @columns.first
  end

  def to
    @columns.last
  end

   # [cola, colb, colc] > [colc] 
   # [cola, colb] > []
   # [cola] > nil hence the || []
  def skipped
    (@columns.slice(1, @columns.length - 2) || [])
  end

  def delta
    to_index - from_index
  end

  def valid?
    @columns.length > 1
  end

  def section_boundary?
    @columns.first.section != @columns.last.section
  end

end