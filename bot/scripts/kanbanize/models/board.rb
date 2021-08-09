require_relative 'section'
require 'forwardable'

class Board
  extend Forwardable

  attr_reader :id

  def_delegators :@structure, :add_structural_column, :sections

  def initialize(id)
    @id = id
    @structure = BoardStructure.new(id)
  end

  def throughput
    sections.each_value.collect{|s| s.task_names }.flatten.uniq.count
  end

  def add_column_task_duration(column:, task:, entry_at:, exit_at:, entry_history_event:, exit_history_event:)
    columns = @structure.sections.each_value.collect do |section|
      section.find_column(column)
    end.compact

    raise "more than one column found for #{column} : #{columns}" if columns.length > 1

    column = columns.first

    if column
      column.add_task_duration(
        task: task, 
        entry_at: entry_at, 
        exit_at: exit_at,
        entry_history_event: entry_history_event,
        exit_history_event: exit_history_event
      )
    else
      dead_letter << { column: column, task: task, entry_at: entry_at, exit_at: exit_at, entry_history_event: entry_history_event, exit_history_event: exit_history_event }
    end
  end

  def dead_letter
    @dead_letter ||= []
  end
end

class BoardStructure
  attr_reader :id

  def initialize(id)
    @id = id
  end

  def add_structural_column(section:, position:, lcname:, flow_type:, children:)
    sections[section] ||= Section.new(section)
    sect = sections[section]
    sect.add_structural_column(
      position: position,
      lcname: lcname,
      flow_type: flow_type,
      children: children
    )
  end

  def sections
    @sections ||= {}
  end
end