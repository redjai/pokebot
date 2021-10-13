module HistoryDetails
  class Work

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
      entry.is_a?(Transition) && exit.is_a?(Transition) && entry.to_name.to_s == exit.from_name.to_s
    end

    def created?
      entry.history_event == 'Task created'
    end

    def archived?
      exit.history_event == 'Task archived'
    end

  end
end