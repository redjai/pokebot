module HistoryDetails
  class Transition < HistoryDetail

    attr_accessor :columns

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

    # columns is an assigned column range.
    def indexed?
      !@columns.nil?
    end

    def delta
      @columns.delta
    end

    def from
      @columns.from
    end

    def to
      @columns.to
    end

    def from_index
      @columns
    end

  end
end