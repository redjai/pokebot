require_relative 'section'

class Board

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def tasks
    @task ||= TasksCollection.new
  end

  def throughput
    sections.each_value.collect{|s| s.task_names }.flatten.uniq.count
  end
  
  def find_column(name)
    columns = sections.each_value.collect do |section|
      section.find_column(name)
    end.compact

    raise "more than one column found for #{name} in #{columns}" if columns.length > 1
    
    columns.first
  end

  def dead_letter
    @dead_letter ||= []
  end

  def find_section(section_name)
    sections[section_name] ||= Section.new(section_name)
    sect = sections[section_name]
  end

  def sections
    @sections ||= {}
  end

end