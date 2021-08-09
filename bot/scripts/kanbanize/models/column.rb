require 'forwardable'
require_relative 'stats'

class Column
  extend Forwardable

  attr_reader :data

  def_delegators :@structure, :children?, :children, :name, :flow_type, :queue?, :position 
  def_delegators :@data, :add_task_duration, :task_durations, :strangers, :short_stayers, :created, :archived, :throughput, :task_names

  def initialize(position:, lcname:, flow_type:, parent: nil, children:[])
    @structure = ColumnStructure.new(
      position: position, 
      lcname: lcname, 
      flow_type: flow_type,
      parent: parent, 
      children: children
    )
    @data = ColumnData.new
  end

  def stats
    if children?
      TaskDurationStats.new(children).hydrate!
    else
      TaskDurationStats.new(self).hydrate!
    end
  end
end

class TaskDuration
  attr_reader :task, :entry_at, :exit_at, :entry_history_event, :exit_history_event

  def initialize(task:, entry_at:, exit_at:, entry_history_event:, exit_history_event:)
    @task = task
    @entry_at = entry_at
    @exit_at = exit_at
    @entry_history_event = entry_history_event
    @exit_history_event = exit_history_event
  end

  def duration
    @duration ||= entry_at && exit_at ? ((exit_at.to_time - entry_at.to_time) / 3600.0).round : nil
  end

  def short?
    @duration && @duration.to_i == 0
  end

  def created?
    @entry_history_event == 'Task created'
  end

  def archived?
    @exit_history_event == 'Task archived'
  end
end

class ColumnData

  def task_names
    task_durations.collect{|td| td.task }.uniq.sort
  end

  def throughput
    task_names.count
  end

  def task_durations
    @task_durations ||= []
  end

  def add_task_duration(task:, entry_at:, exit_at:, entry_history_event:, exit_history_event:)
    task_durations << TaskDuration.new(
      task: task, 
      entry_at: entry_at, 
      exit_at: exit_at,
      entry_history_event: entry_history_event,
      exit_history_event: exit_history_event
    )
  end

  def strangers(all_tasks)
    all_tasks_names = all_tasks.collect{ |task_duration| task_duration.task }
    task_durations_names = task_durations.collect{ |task_duration| task_duration.task }
    all_tasks_names - task_durations_names
  end

  def created
    task_durations.select{|task_duration| task_duration.created? }
  end

  def archived
    task_durations.select{|task_duration| task_duration.archived? }
  end

  def short_stayers
    task_durations.select{ |task_duration| task_duration.short? }
  end
end

class ColumnStructure

  attr_reader :parent, :position, :lcname, :flow_type, :children

  def initialize(position:, lcname:, flow_type:, parent: nil, children:[])
    @parent = parent
    @position = position
    @lcname = lcname
    @flow_type = flow_type
    @child_data = (children || [])
  end

  def queue?
    @flow_type == "queue"
  end

  def children?
    !children.empty?
  end

  def name
    parent.nil? ? lcname : "#{parent.lcname}.#{lcname}"
  end

  def children
    @children ||= begin
      @child_data.collect do |child| Column.new(
        position: child["position"],
        lcname: child["lcname"],
        flow_type: child["flowtype"],
        parent: self)
      end
    end
  end
end