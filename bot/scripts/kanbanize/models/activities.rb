require_relative 'report_dates'

class Activities
include ReportDates

  def year(date: Date.today)
    process!(((date - 200)..date))
  end

  def week(date: Date.today)
    process!(week_range(date: date))
  end

  def day(date:)
    process! (date..date)  
  end

  def initialize(*cols)
    @cols = cols.flatten
  end

  def activities
    @activities ||= {}
  end

  def process!(date_range)
    activities.clear
    date_range.each do |date|
      @cols.each do |col|
        col.task_actions.each do |task_action|
            task_action.actions_on(date).each do |task_movement|
              next if task_movement == "entered" && col != @cols.first
              next if task_movement == "exited" && col != @cols.last
              activities[task_movement] ||= 0
              activities[task_movement] += 1
            end  
        end
      end
    end
    activities
  end
end
