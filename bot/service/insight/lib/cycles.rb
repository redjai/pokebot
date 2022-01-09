
require 'descriptive_statistics'
require_relative 'cycle'

module Service
  module Insight
    class Cycles

      def initialize(team_id:, board_id:, named_cycle:, after:, before:)
        @team_id = team_id
        @board_id = board_id
        @named_cycle = named_cycle
        @after = after
        @before = before
      end


      def cycle
        Cycle.new(
          team_id: @team_id, 
          board_id: @board_id, 
          name: @named_cycle.name, 
          from: @named_cycle.from, 
          to: @named_cycle.to, 
          after: @after, 
          before: @before, 
          percentile: percentile
        )
      end
  
      def percentile(percentile: 85)
        durations.percentile(percentile)
      end

      def durations
        task_cycles.values.collect do |task_cycle|
          (DateTime.parse(task_cycle['to'].date) - DateTime.parse(task_cycle['from'].date)).to_f
        end.delete_if{ |duration| duration < 0 } # remove any odd movements where cards may have gone backwards..
      end

      def task_cycles
        @task_cycles ||= begin
          all_cycles = {}
          add_movements( hash: all_cycles, movements: from_movements, from_or_to: 'from' )  # to is when we enter that 'from' column
          add_movements( hash: all_cycles, movements: to_movements, from_or_to:  'to' ) # from is when we exit that 'to' column
          all_cycles.delete_if{ |task_id, movements| movements['from'].nil? || movements['to'].nil? }
        end
      end
    
      def from_movements
        # we enter the cycle 'from' column when the movement 'to' is that column
        Service::Insight::Storage::Movements.fetch_to(team_id: @team_id, board_id: @board_id, after: @after, before: @before, to: @named_cycle.from)
      end

      def to_movements
        # we exit the cycle 'to' column when the movement 'from' is that column
        Service::Insight::Storage::Movements.fetch_from(team_id: @team_id, board_id: @board_id,  after: @after, before: @before, from: @named_cycle.to)
      end
  
      def add_movements(hash:, movements:, from_or_to:)
        movements.each do |movement|
          hash[movement.task_id] ||= {}
          raise "boom" if hash[movement.task_id][from_or_to]
          hash[movement.task_id][from_or_to] = movement
        end
      end
    end
  end
end
  