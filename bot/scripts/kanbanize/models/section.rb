require_relative 'column'

class Section

  attr_reader :name

  def initialize(name)
   @name = name
  end

  def task_actions
    all_columns.collect{ |c| c.task_actions }.flatten
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
    @columns ||= ColumnsHash.new
  end

  def actions_on(date)
    columns.values.collect do |column|
      column.actions_on(date)
    end.flatten
  end

  def actions_on(date)
    actions = []
    actions << columns.first.task_actions.entries_on(date)
    actions << columns.last.task_actions.exits_on(date)
    actions << columns.collect{ |edge| edge.task_actions.waits_on(date) }
    actions.flatten
  end

  def test_actions_on(date)
    columns.edge_task_actions.each{|task_actions| task_actions.all_on()  }
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
    columns.each_value.collect do |column|
      if column.children?
        column.children.values
      else
        column
      end
    end.flatten
  end
end