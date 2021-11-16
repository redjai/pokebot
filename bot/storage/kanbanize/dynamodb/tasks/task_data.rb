class TaskData

  def initialize(team_id:, kanbanize_data:)
    @kanbanize_data = kanbanize_data
    @team_id = team_id
  end

  def history_details
    @history_details ||= @kanbanize_data['historydetails'].sort_by{ |history_detail| history_detail['historyid'] }
  end

  def movements
    @movements ||= history_details.collect{ |history_detail| Movement.build( team_id: @team_id,
                                                                            board_id: @board_id,
                                                                      history_detail: history_detail) }.compact.sort_by{ |movement| movement.history_detail.id }
    end                                                           
  end

  def stays!
    movements.each do |movement|
      column_stays[movement.from_name] ||= Stay.new(:column)
      column_stays[movement.to_name] ||= Stay.new(:column)
      column_stays[movement.from_name].entry = movement
      column_stays[movement.to_name].exit = movement

      if movement.section_boundary?
        section_stays[movement.from_name] ||= Stay.new(:section)
        section_stays[movement.to_name] ||= Stay.new(:section)
        section_stays[movement.from_name].entry = movement
        section_stays[movement.to_name].exit = movement
      end
    end
  end

  def section_stays
    @section_stays ||= {}
  end

  def column_stays
    @column_stays ||= {}
  end

  def created_at
    DateTime.parse(history_details.first['entrydate']).iso8601
  end

  def updated_at
    DateTime.parse(history_details.last['entrydate']).iso8601
  end

  def id
    "#{@team_id}-#{@kanbanize_data['historyid']}"
  end

  def hydrate!
    @kanbanize_data['id'] = id
    @kanbanize_data['team_id'] = @team_id
  end

  def data
    hydrate!
    @kanbanize_data
  end

end