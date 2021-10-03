class Card # this is an imported kanbanize card

  def self.current_cards
    @@current ||= cards.select do |card|
      card.current?
    end
  end

  def id
    @data['taskid']
  end

  def initialize(data)
    @data = data
  end

  def board_id
    @data['boardid']
  end

  def history_details
    @history_details ||= HistoryDetails::Collection.new(_history_details)
  end

  def base_history_details
    history_details.collect do |detail|
      detail['details'].gsub(/'[^']+'/,'')
    end
  end

  def section_cycle_times
    sections = {}
    transitions.each do |transition|
      if transitions.section_boundary?
        bounds[transition.from_name] = mov
      end
    end
  end

  # all waits must be in existing columns
  def current?
    waits.find do |wait|
      !board.edge_column_exists?(wait.column_name)
    end.nil?
  end

  private

  def _history_details
    (@data['historydetails'] || []).sort_by{ |a| a["historyid"] }.collect do |history_detail|
      HistoryDetails.build(history_detail)
    end
  end

end