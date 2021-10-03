class CardData

  def data
    @data ||= []
  end

  def load!
    paths = Dir.glob("data/**/*.json")
    paths.each do |path|
      data << JSON.parse(File.read(path))
    end
  end

  def cards
    @cards ||= begin
      data.collect do |data|
        Card.new(data)
      end
    end
  end

  def index_movements!(board_structures)
    cards.each do |card|
      card.history_details.column_movements.each do |movement|
        board = board_structures[card.board_id]
        next unless board
        edges = board.columns.edges
        from = edges.find{ |edge| edge.lcname == movement.from_name }
        to = edges.find{ |edge| edge.lcname == movement.to_name }
        movement.from_index = edges.index(from)
        movement.to_index = edges.index(to)
      end
    end
  end

  def update_boards(boards)
    cards.each do |card|
      board = boards[card.board_id]
      board.cards << card if board
    end
  end

  def authors
    @authors ||= begin
      authors = {}
      cards.each do |card|
        card.history_details.each do |history_detail|
          authors[history_detail.author] ||=  Author.new(history_detail.author)
          authors[history_detail.author].history_details << history_detail
        end
      end
      authors
    end
    
  end
end