require 'csv'
require 'json'
require 'descriptive_statistics'
require 'caxlsx'

require_relative 'models/boards'

boards = Boards.new
boards.build!
boards.load_data(ARGV.first)

boards.boards.each_value do |board|
  board.sections.each_value do |section|
    puts "#{board.id} - #{section.name}"
    date = Date.civil(2021,5,31)
    
    section.columns.each_value do |column|
      puts column.lcname
      (date..(date + 4)).each do |date|
        puts column.grouped_actions_on(date).inspect
      end
    end
    
  end
end


Axlsx::Package.new do |p|

  p.workbook.add_worksheet(:name => "Activities") do |sheet|
    sheet.add_row(["board","section"])
    boards.boards.each_value do |board|
      board.sections.each_value do |section|
        sheet.add_row([])
        sheet.add_row([board.id, section.name])
        sheet.add_row(["","created", "entered","waited","exited","archived"])
        date = Date.civil(2021,5,31)
        (date..(date + 30)).each do |date|
          activities = section.activities.day(date: date)
          sheet.add_row([
            date.to_s,
            activities['created'].to_i.to_s,
            activities['entered'].to_i.to_s,
            activities['waited'].to_i.to_s,
            (0 - activities['exited'].to_i).to_s,
            (0 - activities['archived'].to_i).to_s
          ])
        end
      end
    end
  end
  p.serialize('/tmp/simple.xlsx')
end

raise "boom"
Axlsx::Package.new do |p|
  p.workbook.add_worksheet(:name => "All Columns") do |sheet|
    boards.boards.each_value do |board|
      board.sections.each_value do |section|
        section.all_columns.each do |column|
          sheet.add_row([
            board.id,
            section.name,
            column.name,
            column.stats.durations_without_outliers.mean.to_i,
            column.stats.durations_without_outliers.standard_deviation.to_i,
            column.stats.durations_without_outliers.mean.to_i + column.stats.durations_without_outliers.standard_deviation.to_i,
            column.created.count,
            column.archived.count
          ])
        end
      end
    end
  end

  p.workbook.add_worksheet(:name => "Sections") do |sheet|
    boards.boards.each_value do |board|
      board.sections.each_value do |section|
        next if section.stats.tasks == {}
        sheet.add_row(
          section.name,
          section.stats.durations_without_outliers.mean,
          section.stats.durations_without_outliers.standard_deviation
        )
        puts "  #{section.name}:"
    puts "    #{section.stats.throughput} tasks"
    
    puts "    #{} out of #{section.stats.tasks.count} tasks impeded after #{(section.stats.durations_without_outliers.mean + section.stats.durations_without_outliers.standard_deviation).to_i} hours. mean: #{section.stats.durations_without_outliers.mean.to_i} hours, 1 standard deviation: #{section.stats.durations_without_outliers.standard_deviation.to_i} hours"
    puts "    #{section.created.count} tasks created in this column"
    puts "    #{section.archived.count} tasks archived in this column"


        section.all_columns.each do |column|
          sheet.add_row([
            board.id,
            section.name,
            column.name,
            column.stats.durations_without_outliers.mean.to_i,
            column.stats.durations_without_outliers.standard_deviation.to_i,
            column.stats.durations_without_outliers.mean.to_i + column.stats.durations_without_outliers.standard_deviation.to_i,
            column.created.count,
            column.archived.count
          ])
        end
      end
    end
  end

  p.serialize('/tmp/simple.xlsx')
end

puts
puts "***************************"
puts "Column Stats: "
puts "***************************"
puts 

boards.boards.each_value do |board|
  puts
  puts "********************"
  puts "KANBANIZE BOARD #{board.id}"
  puts

  board.sections.each_value do |section|
     puts "  #{section.name}"
     section.all_columns.each do |column|
       next unless column.stats.durations_without_outliers.mean
       puts "    #{column.name}"
       puts "       #{column.stats.throughput} tasks:"
       puts "       tasks stayed #{column.stats.durations_without_outliers.mean.to_i} hours on average, 1 standard deviation: #{column.stats.durations_without_outliers.standard_deviation.to_i} hours"
       puts "       #{column.stats.impeded.count} impeded after #{(column.stats.durations_without_outliers.mean + column.stats.durations_without_outliers.standard_deviation).to_i} hours (impedence > mean + varition)"
       puts "       #{column.short_stayers.count} stayed less than 1 hour"
       puts "       #{column.created.count} tasks created in this column"
       puts "       #{column.archived.count} tasks archived in this column"
       puts
     end
  end
end

puts
puts "***************************"
puts "Grouped Column Stats: "
puts "***************************"
puts 

boards.boards.each_value do |board|
  puts
  puts "********************"
  puts "KANBANIZE BOARD #{board.id}"
  puts
  board.sections.each_value do |section|
     puts "  #{section.name}"
     section.columns.each do |column|
       puts "  #{column.stats.throughput} tasks:"
       next unless column.stats.durations_without_outliers.mean
       puts "  #{column.name}"
       puts "  #{column.stats.impeded.count} out of #{column.stats.tasks.count} tasks impeded after #{(column.stats.durations_without_outliers.mean + column.stats.durations_without_outliers.standard_deviation).to_i} hours. mean: #{column.stats.durations_without_outliers.mean.to_i} hours, 1 standard deviation: #{column.stats.durations_without_outliers.standard_deviation.to_i} hours"
       puts
     end
  end
end

puts
puts "***************************"
puts "Section Stats: "
puts "***************************"
puts 

boards.boards.each_value do |board|
  puts
  puts "********************"
  puts "KANBANIZE BOARD #{board.id}:"
  puts

  board.sections.each_value do |section|
    puts "  #{section.name}:"
    puts "    #{section.stats.throughput} tasks"
    next if section.stats.tasks == {}
    puts "    #{section.stats.impeded.count} out of #{section.stats.tasks.count} tasks impeded after #{(section.stats.durations_without_outliers.mean + section.stats.durations_without_outliers.standard_deviation).to_i} hours. mean: #{section.stats.durations_without_outliers.mean.to_i} hours, 1 standard deviation: #{section.stats.durations_without_outliers.standard_deviation.to_i} hours"
    puts "    #{section.created.count} tasks created in this column"
    puts "    #{section.archived.count} tasks archived in this column"

  end
end

puts
puts "***************************"
puts "Section Queue Column Stats: "
puts "***************************"
puts 

boards.boards.each_value do |board|
  puts
  puts "********************"
  puts "KANBANIZE BOARD #{board.id}"
  puts

  board.sections.each_value do |section|
     puts "  #{section.name}"
     puts "   #{section.stats.throughput} tasks:" 
     section.queues.each do |column|
       next unless column.stats.durations_without_outliers.mean
       puts "    #{column.name}"
       puts "       #{column.stats.impeded.count} out of #{column.stats.tasks.count} tasks impeded after #{(column.stats.durations_without_outliers.mean + column.stats.durations_without_outliers.standard_deviation).to_i} hours. mean: #{column.stats.durations_without_outliers.mean.to_i} hours, 1 standard deviation: #{column.stats.durations_without_outliers.standard_deviation.to_i} hours"
       puts "       #{column.task_durations.strangers(section.task_durations).count} tasks out of #{section.task_durations.count} did not queue in this column"
       puts "       #{column.short_stayers.count} tasks out of #{section.all_task_durations.count} queued for less than 1 hour"
     end
  end
end


