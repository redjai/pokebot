class TaskActionsCollection < Array

   def entries_on(date)
     each.collect do |task_action|
       task_action.entries_on(date)
     end.flatten.compact
   end

   def exits_on(date)
     each.collect do |task_action|
       task_action.exits_on(date)
      end.flatten.compact
   end

   def waits_on(date)
      each.collect do |task_action|
        task_action.waits_on(date)
      end.flatten.compact
   end

   def all_on(date)
     each.collect do |task_action|
       task_action.all_on(date)
     end.flatten.compact
   end
end

class TaskAction

  OFFICE_START_HOUR = 9
  OFFICE_END_HOUR = 18
  MIN_DAY = 4

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
    @date_range ||= (entry_at_date..exit_at_date)
  end

  module Actions
    ENTERED = "entered"
    EXITED = "exited"
    WAITED = "waited"
    CREATED = "created"
    ARCHIVED = "archived"
  end

  def wait_length(date)
    start = (date == entry_at_date ? entry_at.hour : OFFICE_START_HOUR)
    finish = (date == exit_at_date ? exit_at.hour : OFFICE_END_HOUR)
    finish - start          
  end
  
  def waits_on(date)
    return [] unless date_range.include?(date)
    if wait_length(date) > MIN_DAY
      Actions::WAITED
    end
  end

  def entries_on(date)
    return [] unless date_range.include?(date)
    if date == entry_at_date
      created? ? Actions::CREATED : Actions::ENTERED
    end
  end

  def exits_on(date)
    return [] unless date_range.include?(date)
    if date == exit_at_date
      archived? ? Actions::ARCHIVED : Actions::EXITED
    end
  end

  def all_on(date)
    actions = []
    actions << entries_on(date)
    actions << exits_on(date)
    actions << waits_on(date)
    actions.flatten.compact
  end

  def exit_at_date
    @exit_at_date ||= exit_at.to_date
  end

  def entry_at_date
    @entry_at_date ||= entry_at.to_date
  end
end