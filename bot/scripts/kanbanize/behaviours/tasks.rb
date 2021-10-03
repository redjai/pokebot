# aws s3 cp s3://gerty-development-kanbanize-imports/tasks /tmp/ --recursive --profile red-queen

require_relative 'board_structure'
require_relative 'card_data'
require_relative 'card'
require_relative 'author'
require_relative 'month'
require_relative 'wait'
require_relative 'history_details/history_details'

require 'descriptive_statistics'

# board.cards.columns.waits
                     #.transitions

def print_section(section, durations)
  #puts durations.sort.inspect
  puts "#{section} - 85% completed in #{remove_outliers(durations).percentile(85).round(0)} days"
end

def remove_outliers(array)
  return [] if array.empty?
  array = array.delete_if{|d| d <  0}

  q1 = array.descriptive_statistics[:q1]
  q3 = array.descriptive_statistics[:q3]
  diff = (q3 - q1).to_f
  min = q1 - 1.5 * diff
  max = q3 + 1.5 * diff
  array.select{ |n| n > min || n < max }
end

boards = BoardStructure.new
boards.build!

card_data = CardData.new
card_data.load!

card_data.index_movements!(boards.boards)
card_data.update_boards(boards.boards)

authors = card_data.authors

june = Month.range(month: 6)
july = Month.range(month: 7)
date_range = (june.first..july.last)

puts "****************"
puts " Users"
puts "****************"
puts
puts "How they move cards."
puts "% of cards that a user has moved to the next sequential column on the board"
puts "-------------------"
authors.values.sort_by(&:good_moves_as_percent).each do |author|
  puts "#{author.name} #{author.good_moves_as_percent}% of #{author.history_details.indexed_column_movements.count} moved to next column."
end

puts
puts "When they move cards"
puts "% of cards that the user has moved in a group i.e. within #{(Author::MOVE_INTERVAL / 60).to_i} minutes from moving any other card."
puts "--------------------"
authors.values.sort_by(&:bad_times_as_percent).reverse.each do |author|
  puts "#{author.name} #{author.bad_times_as_percent}% of #{author.times.count} moved as a group"
end

puts 
puts "Do they create and archive ?"
puts "Is the user acting as a creator and archiver of cards."
puts "--------------------"
authors.values.sort_by{|author| author.history_details.created.count }.reverse.each do |author|
  puts "#{author.name} created #{author.history_details.created.count} cards archived #{author.history_details.archived.count} cards"
end

puts "\n\n\n"
puts "****************"
puts " Columns"
puts "****************"

puts
puts "WAITING"
puts "how many tickets wait in a column and typically how long for"
puts "--------------------"
boards.boards.each_value do |board|
  puts
  puts "Board #{board.id}"
  board.columns.edges.each do |edge|
    waits = board.waits[edge.lcname]
    if waits
      durations = waits.collect{ |wait| wait.duration } 
      created = waits.select{|wait| wait.created? }.count
      archived = waits.select{|wait| wait.archived? }.count
      puts "#{edge.lcname}: #{waits.length} tickets out of #{}. #{created} tickets created in this column, #{archived} tickets archived. 85% of cards completed in #{durations.percentile(85).round(0)} days" 
    else
      puts "#{edge.lcname} - NO DATA"
    end
  end
end

puts
puts "MOVING"
puts "Where do tickets move to after this column..."
puts "([N/A] means that the ticket moved to a column no longet on the board)"
boards.boards.each_value do |board|
  puts
  puts "Board #{board.id}"
  board.columns.edges.each do |edge|
    transitions = board.transitions.group_by_from_column[edge.lcname]
    next unless transitions
    counts = {}
    transitions.each do |transition|
      counts[transition.to_name] ||= { count: 0, delta: board.columns.delta(transition.from_name, transition.to_name) }
      counts[transition.to_name][:count] += 1
    end
    counts.sort_by { |to, count| count[:count] }.reverse.each do |arr|
      puts "#{edge.lcname} to #{arr.first} - moved #{arr.last[:delta] || '[N/A]'} columns #{arr.last[:count]} times"
    end
  end 
end

puts "\n\n\n"
puts "**********************"
puts " Section Cycle Times"
puts "**********************"



boards.boards.each_value do |board|
  sections = {}

  board.cards.each do |card|
    board.card_section_boundaries(card, date_range: date_range).each do |section, entries_and_exits|
      sections[section] ||= []
      delta = (entries_and_exits[:exit] - entries_and_exits[:entry]).to_f
      sections[section] << delta
    end
  end

  puts
  puts "Board #{board.id}"
  print_section('backlog', sections['backlog'])
  print_section('requested', sections['requested'])
  print_section('progress', sections['progress'])
  print_section('done', sections['done'])
end




