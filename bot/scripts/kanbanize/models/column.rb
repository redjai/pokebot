require 'forwardable'
require_relative 'stats'
require_relative 'task'
require_relative 'activities'
require_relative 'report_dates'

class ColumnsCollection < Hash

  def ordered
    values.sort{ |a,b| a.position <=> b.position }
  end

  def first
    ordered.first
  end

  def last
    ordered.last
  end

end

class Column
  include ReportDates

  attr_reader :position, :lcname, :flow_type, :children

  def initialize(position:, lcname:, flow_type:, children:[])
    @position = position
    @lcname = lcname
    @flow_type = flow_type
  end

  def grouped_actions_on(date)
    grouped = {}
    actions_on(date).each do |action_on|
      grouped[action_on] ||= 0
      grouped[action_on] += 1
    end
    grouped
  end

  def actions_on(date)
    if children?
      actions = []
      actions << children.first.task_actions.entries_on(date) 
      actions << children.last.task_actions.exits_on(date)
      actions << children.each_value.collect{ |column| column.task_actions.waits_on(date) }
      actions.flatten
    else
      task_actions.all_on(date)
    end
  end

  def task_actions
    @task_actions ||= TaskActionsCollection.new
  end

  def queue?
    @flow_type == "queue"
  end

  def children
    @children ||= ColumnsCollection.new
  end

  def children?
    !children.empty?
  end

  def name
    parent.nil? ? lcname : "#{parent.lcname}.#{lcname}"
  end

  def stats
    if children?
      TaskActionStats.new(children).hydrate!
    else
      TaskActionStats.new(self).hydrate!
    end
  end
end
