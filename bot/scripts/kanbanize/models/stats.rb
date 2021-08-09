class TaskDurationStats

  attr_reader :cols

  def tasks
    @tasks ||= {}
  end

  def task_names
    tasks.keys
  end

  def throughput
    task_names.count
  end

  def initialize(*cols)
    @cols = cols.flatten
  end

  def hydrate!
    @cols.each do |column|
      column.task_durations.each do |task_duration|
        add(task_duration)
      end
    end
    self
  end

  def add(task_duration)
    tasks[task_duration.task] ||= []
    tasks[task_duration.task] << task_duration.duration.to_i
    self
  end

  def durations
    @durations ||= filtered_tasks.each_value.collect{ |task_durations| task_durations.sum }
  end

  def durations_without_outliers
    durations - outliers
  end

  #ignore anything with zero sum behaviours
  # for single column stats this would be duration [0]
  # for multi column duration [0,0,0] 
  def filtered_tasks
    tasks.select{ |task, durations| durations.sum > 0 } 
  end

  def impeded
    durations.select{ |duration| duration > mean + standard_deviation }
  end

  def mean
    @mean ||= durations_without_outliers.mean
  end
  
  def standard_deviation
    @standard_deviation ||= durations_without_outliers.standard_deviation
  end

  def outliers
    return [] if durations.empty?
    q1 = durations.descriptive_statistics[:q1]
    q3 = durations.descriptive_statistics[:q3]
    diff = (q3 - q1).to_f
    min = q1 - 1.5 * diff
    max = q3 + 1.5 * diff
    durations.select{ |n| n < min || n > max }
  end
  
end