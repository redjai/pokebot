require 'forwardable'
require_relative 'stats'
require_relative 'task'
require_relative 'activities'
require_relative 'report_dates'

class ColumnsResult < Array

  def actions_on(date)
    actions = []
    actions << first.task_actions.entries_on(date)
    actions << last.task_actions.exits_on(date)
    actions << collect{ |edge| edge.task_actions.waits_on(date) }
    actions.flatten
  end

  def grouped_actions_on(date)
    grouped = {}
    actions_on(date).each do |action_on|
      grouped[action_on] ||= 0
      grouped[action_on] += 1
    end
    grouped
  end

  def actions_between(date_range)
    date_range.collect do |date|
      actions_on(date)
    end.flatten.sort
  end

  def grouped_actions_between(date_range)
    grouped = {}
    actions_between(date_range).each do |action_on|
      grouped[action_on] ||= 0
      grouped[action_on] += 1
    end
    grouped
  end

end

class ColumnsHash < Hash

  def ordered
    values.sort{ |a,b| a.position <=> b.position }
  end

  def edges
    @edges ||= begin
      edges = [] # can't use collect/flatten as we need a very specific order..
      ordered.each do |column|
        if column.children?
          column.children.ordered.each do |child|
            edges << child
          end
        else
          edges << column
        end 
      end
      ColumnsResult.new(edges)
    end
  end

  def queues
    @queues ||= begin
      queues = []
      ordered.each do |column|
        if column.children?
          column.children.ordered.each do |child|
            queues << child if child.queue?
          end
        else
          queues << column if column.queue?
        end 
      end
      ColumnsResult.new(queues)
    end
  end

end

class Column
  include ReportDates

  attr_reader :position, :lcname, :flow_type, :children

  def initialize(position:, lcname:, flow_type:, children:[])
    @position = position
    @lcname = lcname.upcase
    @flow_type = flow_type
  end

  def task_actions
    @task_actions ||= TaskActionsCollection.new
  end

  def queue?
    @flow_type == "queue"
  end

  def children
    @children ||= ColumnsHash.new
  end

  def children?
    !children.empty?
  end

  def stats
    if children?
      TaskActionStats.new(children).hydrate!
    else
      TaskActionStats.new(self).hydrate!
    end
  end
end
