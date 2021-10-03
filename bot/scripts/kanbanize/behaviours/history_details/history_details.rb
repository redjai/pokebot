require_relative 'history_detail'
require_relative 'block'
require_relative 'comment'
require_relative 'custom_field_added'
require_relative 'custom_field_deleted'
require_relative 'custom_field_changed'
require_relative 'deleted'
require_relative 'exceeded_limit'
require_relative 'mention'
require_relative 'notification'
require_relative 'reached_limit'
require_relative 'stickers'
require_relative 'transition'
require_relative 'unarchive'
require_relative 'update'


module HistoryDetails

  def self.build(history_detail)
    klazz(history_detail['eventtype']).new(history_detail)
  end

  def self.klazz(event_type)
    const_get(event_type.gsub(/s$/,"").split(" ").collect do |bit|
      bit.capitalize
    end.join(""))
  end

  class Wait

    attr_accessor :entry, :exit

    def initialize(entry:, exit:)
      @entry = entry
      @exit = exit
    end

    def column_name
      entry.to_name if entry.is_a?(Transition)
      exit.from_name if exit.is_a?(Transition)
    end

    def section
      entry.to.section if entry.is_a?(Transition) && entry.indexed?
      exit.from.section if exit.is_a?(Transition) && exit.indexed?
    end

    def duration
      exit.entry_date - entry.entry_date
    end

    def valid?
      entry.is_a?(Transition) && exit.is_a?(Transition) && entry.to_name != exit.from_name
    end

    def created?
      entry.history_event == 'Task created'
    end

    def archived?
      exit.history_event == 'Task archived'
    end

  end

  class Collection < Array

    def waits
      @waits ||= begin
        waits = []
        if created.first
          waits << Wait.new(entry: created.first, exit: column_movements.first)
        end
        column_movements.each_cons(2) do |entry, exit| 
          wait = Wait.new(entry: entry, exit: exit)
          waits << wait if wait.valid?
        end
        if archived.first
          waits << Wait.new(entry: column_movements.last, exit: archived.first)
        end
        waits
      end
    end

    def get(type:)
      select do |history_detail|
        history_detail.event_type == type
      end.sort_by{ |history_detail| history_detail.entry_date }
    end

    def section_entry(section)
      entry_wait = waits.find do |wait|
        wait.section == section
      end
      entry_wait.entry.entry_date if entry_wait
    end

    def section_exit(section)
      exit_waits = waits.select do |wait|
        wait.section == section
      end
      exit_waits.last.exit.entry_date unless exit_waits.empty?
    end

    def movements
      @movements ||= begin
        movements = column_movements
        return [] if movements.empty?
        movements << created if created
        movements << archived if archived
        movements.flatten.sort_by{ |history_detail| history_detail.entry_date }
      end
    end

    def column_movements
      get(type: 'Transitions').select{ |transition| transition.column_movement? }
    end

    def comments
      get(type: 'Comments')
    end

    def blocked
      select{|history_detail| history_detail.is_a?(Block)}
    end

    def subtasks
      get(type: 'Updates').select{ |update| update.history_event == 'Subtask  created'} #GRRR! API has two spaces...
    end

    def indexed_column_movements
      column_movements.select{ |movement| movement.indexed? }
    end

    def created
      @created ||= begin
        select{ |history_detail| history_detail.history_event == 'Task created' }
      end
    end

    def archived
      @archived ||= begin
        select{ |history_detail| history_detail.history_event == 'Task archived' }
      end
    end

  end

end