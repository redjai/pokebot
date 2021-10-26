
require_relative 'column'

class Board

  attr_reader :id

  def initialize(id)
    @id = id
  end

  def cards
    @cards ||= []
  end

  def transitions
    @transitions ||= begin
      cards.collect do |card|
        card.history_details.column_movements
      end.flatten.group_by{ |movement| movement.from_name }
    end
  end

  def works
    @works ||= begin
      cards.collect do |card|
        card.history_details.works
      end.flatten.group_by{ |work| work.column_name }
    end
  end

  def skipped
    @skipped ||= begin
      counts = {}
      cards.collect do |card|
        card.history_details.indexed_column_movements.each do |transition|
          transition.columns.skipped.each do |column|
            counts[column.lcname] ||= 0
            counts[column.lcname] += 1
          end
        end
      end
      counts
    end
  end

  def columns
    @columns ||= Columns.new
  end

  def mentions
    cards.collect do |card|
      card.history_details.mentions
    end.flatten
  end

  def comments 
    cards.collect do |card|
      card.history_details.comments
    end.flatten
  end

end



