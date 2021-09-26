require_relative 'task_action'

class TasksCollection < Hash

  def add(task_id)
    self[task_id] ||= Task.new
    self[task_id]
  end

  def all
    each_value
  end

  def created
    all.select{|task| task_duration.created? }
  end

  def archived
    select{|task_duration| task_duration.archived? }
  end

  def short_stayers
    select{ |task_duration| task_duration.short? }
  end

  def task_names
    collect{|td| td.task }.uniq.sort
  end

  def moves(date)
    collect do |td|
      td.moves(date)
    end.flatten
  end

  def statuses(date)
    collect do |td|
      td.statuses(date)
    end.flatten
  end

  # subtracting, say, all the TDs in a column from those in a section tells us which TDs skipped the columnrations.
  def strangers(parent_tasks_durations_collection)
    parent_tasks_durations_collection.task_names - task_names
  end

end

class Task

  attr_accessor :id

  def initialize(id:)
    @id = id
  end

  def task_actions
    @actions ||= TaskActionsCollection.new
  end

end


