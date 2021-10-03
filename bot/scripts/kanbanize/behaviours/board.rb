
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

  def waits
    @waits ||= begin
      cards.collect do |card|
        card.history_details.waits
      end.flatten.group_by{ |wait| wait.column_name }
    end
  end

  def columns
    @columns ||= Columns.new
  end

  

  def card_section_boundaries(card, date_range: nil)
    sections = {}

    card.transitions(date_range: date_range).sort_by{|m| m.entry_date }.collect do |transition|
      { 
        from: columns.edge(transition.from_name),
        to: columns.edge(transition.to_name),
        at: transition.entry_date
      }
    end.select do |boundary|
      boundary[:from] && boundary[:to] && boundary[:from].section != boundary[:to].section
    end.each do |boundary|
      sections[boundary[:from].section] ||= {}
      sections[boundary[:to].section] ||= {}
      sections[boundary[:from].section][:exit] = boundary[:at] if sections[boundary[:from].section][:exit].nil? || sections[boundary[:from].section][:exit] < boundary[:at]
      sections[boundary[:to].section][:entry] = boundary[:at] if sections[boundary[:from].section][:entry].nil? || sections[boundary[:from].section][:entry] > boundary[:at]
    end

    if card.waits.first && card.waits.first.type == :created
      created_column = columns.edge(card.waits.first.column_name)
      if created_column
        sections[created_column.section] ||= {}
        sections[created_column.section][:entry] = card.waits.first.entry_at
      end
    end 

    if card.waits.last && card.waits.last.type == :archived
      archived_column = columns.edge(card.waits.last.column_name)
      if archived_column
        sections[archived_column.section] ||= {}
        sections[archived_column.section][:exit] = card.waits.last.entry_at
      end
    end

    sections.delete_if{|_, entries_and_exits| !entries_and_exits[:entry] || !entries_and_exits[:exit]}

    sections
  end
end

class Columns < Array

  def edge(column_name)
    edges.find{ |edge| column_name == edge.lcname }
  end

  def column(name)
    columns = sections.each_value.collect do |section|
      section.find_column(name)
    end.compact

    raise "more than one column found for #{name} in #{columns}" if columns.length > 1
    
    columns.first
  end

  def edge_exists?(column_name)
    !edges.find{|col| col.lcname == column_name}.nil?
  end

  def delta(column_a_name, column_b_name)
    edge_a = edge(column_a_name)
    edge_b = edge(column_b_name)
    edges.index(edge_b) - edges.index(edge_a) if edge_a && edge_b
  end

  def edges
    @edges ||= begin
      edges = [] # can't use collect/flatten as we need a very specific order..
      each do |column|
        if column.children?
          column.children.each do |child|
            edges << child
          end
        else
          edges << column
        end 
      end
      edges
    end
  end

  def queues
    @queues ||= begin
      queues = []
      columns.each do |column|
        if column.children?
          column.children.each do |child|
            queues << child if child.queue?
          end
        else
          queues << column if column.queue?
        end 
      end
      queues
    end
  end

end