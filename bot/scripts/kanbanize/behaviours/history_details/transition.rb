module HistoryDetails
  class Transition < HistoryDetail

    attr_accessor :from_index, :to_index

    FROM_TO = Regexp.new("'\s*([^']+)\s*'")

    IGNORE = ["The task was reordered within the same board cell."]

    def from_name
      @from_name ||= cols.first.upcase if cols.first
    end

    def to_name
      @to_name ||= cols.last.upcase if cols.last
    end

    def cols
      detail.scan(FROM_TO).flatten
    end

    def column_movement?
      from_name && to_name && (from_name != to_name)
    end

    def indexed?
      from_index && to_index
    end

    def delta
      to_index - from_index
    end
  end
end