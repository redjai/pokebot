class Author

  MOVE_INTERVAL = 1.0 / (24.0 * 30.0) # days to minutes..

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def history_details
    @history_details ||= HistoryDetails::Collection.new
  end

  def edge_columns
    @edge_columns ||= begin
      counts = {}
      history_details.indexed_column_movements.each do |movement|
        lcname = movement.to.lcname
        counts[lcname] ||= 0
        counts[lcname] += 1
       end
       counts
    end
  end

  def parent_columns
    @parent_columns ||= begin
      counts = {}
      history_details.indexed_column_movements.each do |movement|
        lcname = movement.to.lcname.split(".").first
        counts[lcname] ||= 0
        counts[lcname] += 1
       end
       counts
    end
  end

  def top_parent_column
    parent_columns.to_a.max{ |a,b| a.last <=> b.last }
  end

  def sections
    @sections ||= begin 
      sections = {}
      history_details.indexed_column_movements.each do |movement|
        section = movement.to.section
        sections[section] ||= 0
        sections[section] += 1
       end
      sections
    end 
  end

  def boards
    @boards ||= begin 
      sections = {}
      history_details.indexed_column_movements.each do |movement|
        section = movement.to.board.id
        sections[section] ||= 0
        sections[section] += 1
       end
      sections
    end 
  end

  def uniq?
    at.count - at.uniq.count
  end

  def good_moves
    @good_moves ||= begin
      history_details.indexed_column_movements.select do |column_movement|
        column_movement.delta == 1
      end
    end
  end

  def good_moves_ratio
    return 0 if history_details.indexed_column_movements.empty?
    good_moves.count.to_f / history_details.indexed_column_movements.count.to_f
  end

  def good_moves_as_percent
    (good_moves_ratio * 100.0).to_i
  end

  def times
    @times ||= history_details.column_movements.collect{ |column_movement| column_movement.entry_date }.sort
  end

  def bad_times
    bad = 0
    times.each_cons(2){ |time_a, time_b| bad += 1 if (time_b - time_a).to_f < MOVE_INTERVAL }
    bad
  end

  def bad_times_ratio
    return 0.0 if times.empty?
    bad_times.to_f / times.count.to_f
  end

  def bad_times_as_percent
    (bad_times_ratio * 100.0).to_i
  end

end
