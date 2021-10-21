# aws s3 cp s3://gerty-development-kanbanize-imports/tasks /tmp/ --recursive --profile red-queen

require_relative 'board_structure'
require_relative 'card_data'
require_relative 'card'
require_relative 'author'
require_relative 'month'
require_relative 'history_details/history_details'

require 'descriptive_statistics'

# board.cards.columns.works
                     #.transitions

def print_section(section, durations)
  if durations.empty?
    puts "#{section} - no data"
  else
    puts "#{section} - 85% completed in #{durations.percentile(85).round(0)} days"
  end
end


boards = BoardStructure.new
boards.build!

card_data = CardData.new
card_data.load!
card_data.build_history_details!(after: Date.civil(2021,6,1))
card_data.index_movements!(boards.boards)
card_data.assign_cards_to_boards(boards.boards)

authors = card_data.authors

puts "****************"
puts " Users"
puts "****************"
puts
puts "How they move cards."
puts "% of cards that a user has moved to the next sequential column on the board"
puts "-------------------"
authors.values.sort_by(&:good_moves_as_percent).reverse.each do |author|
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

puts
puts "Where they move cards"
puts "What edge columns do they work on ?"
puts "--------------------"
authors.each_value do |author|
  puts "#{author.name} #{author.edge_columns.inspect}"
end

puts
puts "Where they move cards"
puts "What parent columns do they work on ?"
puts "--------------------"
authors.each_value do |author|
  puts "#{author.name} #{author.top_parent_column} #{author.parent_columns.inspect}"
end

raise "boom" 

puts
puts "Where they move cards"
puts "What sections of the board do they work on ?"
puts "--------------------"
authors.each_value do |author|
  puts "#{author.name} #{author.sections.inspect}"
end

puts
puts "Where they move cards"
puts "What boards do they work on ?"
puts "--------------------"
authors.each_value do |author|
  puts "#{author.name} #{author.boards.inspect}"
end

puts 
puts "Do they comment or get mentioned?"
puts "How many times does the user comment on cards or get mentioned by others"
puts "--------------------"
authors.values.sort_by{|author| author.history_details.comments.count }.reverse.each do |author|
  puts "#{author.name} commented #{author.history_details.comments.count} times and was mentioned #{author.history_details.mentions.count} times"
end


puts 
puts "Do they create subtasks ?"
puts "Is the user creating task subcards."
puts "--------------------"
authors.values.sort_by{|author| author.history_details.subtasks.count }.reverse.each do |author|
  puts "#{author.name} creates #{author.history_details.subtasks.count} subtasks"
end

puts 
puts "Do they mark cards as blocked ?"
puts "Is the user blocking cards"
puts "--------------------"
authors.values.sort_by{|author| author.history_details.blocked.count }.reverse.each do |author|
  puts "#{author.name} blocked cards #{author.history_details.blocked.count} times"
end

puts 
puts "The WIP"
puts "Do they exceed the WIP limit ?"
puts "--------------------"
authors.values.sort_by{|author| author.history_details.exceeded_wip_limit.count }.reverse.each do |author|
  puts "#{author.name} - exceeded WIP limit #{author.history_details.exceeded_wip_limit.count} times"
end

puts 
puts "Columns"
puts "Work in each column of the board"
authors.values.each do |author|
  columns = {}
  boards.boards.each_value do |board|
    board.cards.each do |card|
      card.history_details.works.each do |work|
        next unless work.valid? && work.section # a section can be nil if it's old columns
        if work.entry.author == author.name || work.exit.author == author.name
          columns[work.column_name] ||= {worked: [], skipped: 0}
          columns[work.column_name][:worked] << work.duration
        end
      end
    end
  end
  puts "#{author.name}:"
  boards.boards.each_value do |board|
    puts "board #{board.id}"
    board.columns.edges.each do |edge|
      column = columns[edge.lcname]
      if column
        puts " #{edge.lcname} worked #{column[:worked].length} times, 85% completed in #{column[:worked].percentile(85).round(0)} days"
      end
    end
  end
  puts
end

puts 
puts "Queues"
puts "Do authors use queue columns"
queues = {}
authors.values.each do |author|
  boards.boards.each_value do |board|
    board.cards.each do |card|
      card.history_details.column_movements.each do |transition|
        if transition.author == author.name
          edge = board.columns.edge(transition.to_name)
          if edge && edge.queue?
            queues[author.name] ||= 0
            queues[author.name] += 1
          end
        end
      end
    end
  end
end

queues.sort_by{|author, count| count }.reverse.each do |res|
  puts "#{res.first} has moved cards into a queue column #{res.last} times"
end

puts "\n\n\n"
puts "****************"
puts " Columns"
puts "****************"

puts
puts "Working"
puts "how many tickets in a column and typically how long for"
puts "--------------------"
boards.boards.each_value do |board|
  puts
  puts "Board #{board.id}"
  board.columns.edges.each do |edge|
    works = board.works[edge.lcname]
    if works
      durations = works.collect{ |work| work.duration } 
      created = works.select{|work| work.created? }.count
      archived = works.select{|work| work.archived? }.count
      puts "#{edge.lcname} worked #{works.length} times, skipped #{board.skipped[edge.lcname].to_i} times. #{created} tickets created in this column, #{archived} tickets archived. 85% of cards completed in #{durations.percentile(85).round(0)} days" 
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
    transitions = board.transitions[edge.lcname]
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

puts
puts "Collaborating"
puts "how many tickets in a column and typically how long for"
puts "--------------------"
boards.boards.each_value do |board|
  puts
  puts "Board #{board.id}"
  puts "comments: #{board.comments.count} mentions: #{board.mentions.count}"
end

puts "\n\n\n"
puts "**********************"
puts " Section Cycle Times"
puts "**********************"

puts "Boards"


boards.boards.each_value do |board|
  sections = {}

  board.cards.each do |card|
    %w{ backlog requested progress done }.each do |section|
      sections[section] ||= []
      entry = card.history_details.section_entry(section)
      exit = card.history_details.section_exit(section)
      sections[section] << exit - entry if exit && entry
    end
  end

  puts
  puts "Board #{board.id}"
  print_section('backlog', sections['backlog'])
  print_section('requested', sections['requested'])
  print_section('progress', sections['progress'])
  print_section('done', sections['done'])
end

# puts
# puts "Authors"
# authors.values.each do |author|

#   %w{ backlog requested progress done }.each do |section|
#     sections[section] ||= []
#     entry = author.history_details.section_entry(section)
#     exit = card.history_details.section_exit(section)
#     sections[section] << exit - entry if exit && entry

# end




