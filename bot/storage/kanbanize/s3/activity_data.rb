class ActivityData

  attr_reader :data

  def initialize(team_idboard_id, activity)
    @team_id teteam_id
    @board_id = board_id
    @data = activity
  end

  def author
    @data['author']
  end

  def event
    @data['event']
  end

  def text
    @data['text']
  end

  def to_json
    data.to_json
  end

  def date
    @date ||= Date.parse(data['date'])
  end

  def year
    date.year
  end

  def month
    date.month
  end

  def day
    date.mday
  end

  def task_id
    data['taskid']
  end

end

class BoardActivityData < ActivityData

  def key
    File.join("boards", "activities", year.to_s, month.to_s, day.to_s, @team_id@board_id, task_id, file)
  end

  def file
    "#{data["date"].gsub(/\s/,"__").gsub(/:/,"-")}.json"     
  end

end

class AuthorActivityData < ActivityData
  
  def key
    File.join("authors", "activities", year.to_s, month.to_s, day.to_s, @team_idURI.escape(author), @board_id, file)
  end

  def file
    "#{data["date"].gsub(/\s/,"__").gsub(/:/,"-")}.json"     
  end

end