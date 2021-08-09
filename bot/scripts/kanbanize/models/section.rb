require_relative 'column'

class Section

  attr_reader :name

  def initialize(name)
   @name = name
  end

  def find_column(name)
    all_columns.find{ |col| col.name == name }
  end

  def columns
    @columns ||= []
  end

  def queues
    all_columns.select{|column| column.queue? }
  end

  def stats
    @stats ||= TaskDurationStats.new(all_columns).hydrate!
  end

  def created
    all_columns.collect{|col| col.created }.flatten
  end

  def archived
    all_columns.collect{|col| col.archived }.flatten
  end

  def add_structural_column(position:, lcname:, flow_type:, children:)
    parent_pos = (position.to_i * 100) + 100
    if children
      children.each do |child|
        child['position'] = parent_pos + child['position'].to_i + 1
      end
    end
    columns << Column.new(
      position: parent_pos, 
      lcname: lcname, 
      flow_type: flow_type, 
      children: children
    )
  end

  def all_task_durations
    all_columns.collect{|column| column.task_durations }.flatten.uniq
  end

  def all_columns
    columns.collect do |column|
      if column.children?
        column.children
      else
        column
      end
    end.flatten.sort_by(&:position)
  end
end