# aws s3 cp s3://gerty-development-kanbanize-imports/tasks /tmp/ --recursive --profile red-queen

require_relative '../models/boards'
require 'descriptive_statistics'

class Card # this is an imported kanbanize card

  @@cards = []

  attr_accessor :board

  def self.cards
    @@cards
  end

  def id
    @data['taskid']
  end

  def self.load(boards)
    paths = Dir.glob("data/**/*.json")
    paths.each do |path|
      card = new(JSON.parse(File.read(path)))
      board = boards.boards[card.board_id]
      if board
        card.board = board
        @@cards << card
      end
    end
  end

  def initialize(data)
    @data = data
  end

  def board_id
    @data['boardid']
  end

  def history_details
    @data['historydetails']
  end

  def movements
    history_details.select{ |detail| detail['historyevent'] == 'Task moved' }
                   .collect{ |data| movement = Movement.new(@board, data) }
                   .select{ |movement| movement.delta }
  end

end

class Movement

  attr_accessor :board

  FROM_TO = Regexp.new("'([^']+)'")
  
  def initialize(board, history_detail)
    @history_detail = history_detail
    @board = board
  end

  def event
    @history_detail['historyevent']
  end

  def detail
    @history_detail['details']
  end

  def entry_date
    DateTime.parse(@history_detail['entrydate']).to_time.to_i # seconds since epoch
  end

  def author
    @history_detail['author']
  end

  def from
    @from ||= cols.first.first.split(".").last.upcase if cols.first
  end

  def from_index
    @from_index ||= board.edges.index{ |edge| from == edge.lcname }
  end

  def to_index
    @to_index ||= board.edges.index{ |edge| to == edge.lcname }
  end

  def to
    @to ||= cols.last.first.split(".").last.upcase if cols.first
  end

  def cols
    detail.scan(FROM_TO)
  end

  def delta
    to_index - from_index if to_index && from_index
  end
end

class Author

  attr_accessor :name

  def initialize(name)
    @name = name
  end

  def moves
    @movements ||= []
  end

  def at
    @at ||= []
  end

  def uniq?
    at.count - at.uniq.count
  end

  def good_moves
    moves.select{|m| m == 1}
  end

  def good_moves_ratio
    return 0 if moves.empty?
    good_moves.count.to_f / moves.count.to_f
  end

  def good_moves_as_percent
    (good_moves_ratio * 100.0).to_i
  end

  def times
    @times ||= begin
      times = []
      at.sort.each_cons(2) { |a,b| times << (b - a) }
      times
    end
  end

  def good_times
    times.select{|time| time > 600 } #seconds
  end

  def good_times_ratio
    good_times.count.to_f / at.count.to_f
  end

  def good_times_as_percent
    (good_times_ratio * 100.0).to_i
  end

end

boards = Boards.new
boards.build!

Card.load(boards)

authors = {}

Card.cards.each do |card|
  card.movements.each do |movement|
    authors[movement.author] ||=  Author.new(movement.author)
    authors[movement.author].moves << movement.delta
    authors[movement.author].at << movement.entry_date
  end
end

authors.values.sort_by(&:good_moves_as_percent).each do |author|
  puts "#{author.name} #{author.good_moves_as_percent}"
end

puts

authors.values.sort_by(&:good_times_as_percent).each do |author|
  puts "#{author.name} #{author.good_times_as_percent}"
end

scores_on_the_doors = {}

authors.values.each do |author|
  scores_on_the_doors[author.name] = author.good_times_ratio * author.good_moves_ratio
end

puts scores_on_the_doors.sort_by{|name, score| score }.inspect


