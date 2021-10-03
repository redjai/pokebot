
module HistoryDetails

  class HistoryDetail

    def id
      @history_detail['historyid']
    end

    def initialize(history_detail)
      @history_detail = history_detail
    end

    def event_type
      @history_detail['eventtype']
    end

    def history_event
      @history_detail['historyevent']
    end

    def detail
      @history_detail['details']
    end

    def entry_date
      DateTime.parse(@history_detail['entrydate'])
    end

    def entry_date_in_seconds
      entry_date.to_time.to_i # seconds since epoch
    end

    def author
      @history_detail['author']
    end

  end
end
