require_relative 'column'

class Section

  attr_reader :name

  def initialize(name)
   @name = name
  end

  def find_column(name)
    names = name.split(".")
    if names.count == 1
      columns[names.first]
    elsif names.count == 2
      parent  = columns[names.first]
      parent.children[names.last] if parent
    else
      raise "unexpected name #{name}"
    end
  end

  def columns
    @columns ||= ColumnsCollection.new
  end

  def queues
    all_columns.select{|column| column.queue? }
  end

  def activities
    @activities ||= Activities.new(all_columns)
  end
 
  def stats
    @stats ||= TaskActionStats.new(all_columns).hydrate!
  end

  def created
    all_columns.collect{|col| col.task_durations.created }.flatten
  end

  def archived
    all_columns.collect{|col| col.archived }.flatten
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