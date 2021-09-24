class TaskActionsResult < Array

  def to_a
    self
  end

  def to_h
    grouped = {}
    each do |action|
      grouped[action] ||= 0
      grouped[action] += 1
    end
    grouped
  end
end

class TaskActionsCollection < Array
   def entries_on(date)
    TaskActionsResult.new(each.collect do |task_action|
       task_action.entries_on(date)
     end).flatten
   end

   def exits_on(date)
    TaskActionsResult.new(each.collect do |task_action|
       task_action.exits_on(date)
      end.flatten)
   end

   def waits_on(date)
    TaskActionsResult.new(each.collect do |task_action|
        task_action.waits_on(date)
      end.flatten)
   end

   def all_between(date_range)
    TaskActionsResult.new(date_range.collect do |date|
       all_on(date)
     end).flatten
   end

   def all_on(date)
    TaskActionsResult.new(each.collect do |task_action|
       task_action.all_on(date)
     end).flatten
   end
end

class TaskAction

  OFFICE_START_HOUR = 9
  OFFICE_END_HOUR = 18
  MIN_DAY = 12

  attr_reader :entry_at, :exit_at, :entry_history_event, :exit_history_event

  def initialize(entry_at:, exit_at:, entry_history_event:, exit_history_event:)
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

  def date_range
    @date_range ||= duration ? (entry_at_date..exit_at_date) : nil
  end

  module Actions
    ENTERED = "entered"
    EXITED = "exited"
    WAITED = "waited"
    CREATED = "created"
    ARCHIVED = "archived"
  end

  def wait_length_on(date)
    date = date.to_date if date.is_a?(DateTime)
    
    if date_range.first == date
      start = entry_at.hour
    else 
      start = 0
    end

    if date_range.last == date
      finish = exit_at.hour
    else 
      finish = 24
    end

    finish - start  
  end
  
  def waited_on(date)
    return nil unless date_range.include?(date)
    if wait_length_on(date) >= MIN_DAY
      Actions::WAITED
    else
      #puts wait_length(date).to_s + " no wait " + entry_at.to_s + " - " + exit_at.to_s
    end
  end

  def entered_on(date)
    return nil unless date_range.include?(date)
    if date == entry_at_date
      created? ? Actions::CREATED : Actions::ENTERED
    end
  end

  def exited_on(date)
    return nil unless date_range.include?(date)
    if date == exit_at_date
      archived? ? Actions::ARCHIVED : Actions::EXITED
    end
  end

  def all_on(date)
    actions = []
    actions << entered_on(date)
    actions << exited_on(date)
    actions << waited_on(date)
    actions.compact
  end

  def exit_at_date
    @exit_at_date ||= @exit_at ? @exit_at.to_date : nil
  end

  def entry_at_date
    @entry_at_date ||= @entry_at ? @entry_at.to_date : nil
  end
end