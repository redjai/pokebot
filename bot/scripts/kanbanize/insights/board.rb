
require_relative 'column'

class Board

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def cards
    @cards ||= []
  end

  def transitions
    @transitions ||= begin
      cards.collect do |card|
        card.history_details.column_movements
      end.flatten.group_by{ |movement| movement.from_name }
    end
  end

  def works
    @works ||= begin
      cards.collect do |card|
        card.history_details.works
      end.flatten.group_by{ |work| work.column_name }
    end
  end

  def skipped
    @skipped ||= begin
      counts = {}
      cards.collect do |card|
        card.history_details.indexed_column_movements.each do |transition|
          transition.columns.skipped.each do |column|
            counts[column.lcname] ||= 0
            counts[column.lcname] += 1
          end
        end
      end
      counts
    end
  end

  def columns
    @columns ||= Columns.new
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

end

class Columns < Array

  def edge(column_name)
    edges.find{ |edge| column_name == edge.lcname }
  end

  def column(name)
    columns = sections.each_value.collect do |section|
      section.find_column(name)
    end.compact

    raise "more than one column found for #{name} in #{columns}" if columns.length > 1
    
    columns.first
  end

  def edge_exists?(column_name)
    !edges.find{|col| col.lcname == column_name}.nil?
  end

  def delta(column_a_name, column_b_name)
    edge_a = edge(column_a_name)
    edge_b = edge(column_b_name)
    edges.index(edge_b) - edges.index(edge_a) if edge_a && edge_b
  end

  def edges
    @edges ||= begin
      edges = [] # can't use collect/flatten as we need a very specific order..
      each do |column|
        if column.children?
          column.children.each do |child|
            edges << child
          end
        else
          edges << column
        end 
      end
      edges
    end
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