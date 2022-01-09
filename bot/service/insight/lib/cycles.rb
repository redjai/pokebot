
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
          entry: @named_cycle.entry, 
          exit: @named_cycle.exit, 
          after: @after, 
          before: @before, 
          percentile: percentile,
          movements: task_cycles_h
        )
      end
  
      def percentile(percentile: 85)
        durations.percentile(percentile)
      end

      def durations
        task_cycles.values.collect do |task_cycle|
          (DateTime.parse(task_cycle['exit'].date) - DateTime.parse(task_cycle['entry'].date)).to_f
        end.delete_if{ |duration| duration < 0 } # remove any odd movements where cards may have gone backwards..
      end

      def task_cycles_h
        h = {}
        task_cycles.each do |task_id, movements|
          h[task_id] = {}
          h[task_id]['entry'] = movements['entry'].item
          h[task_id]['exit'] = movements['exit'].item
        end
        h
      end

      def task_cycles
        @task_cycles ||= begin
          all_cycles = {}
          add_movements( hash: all_cycles, movements: cycle_entry_movements, action: 'entry' )  # to is when we enter that 'from' column
          add_movements( hash: all_cycles, movements: cycle_exit_movements, action:  'exit' ) # from is when we exit that 'to' column
          all_cycles.delete_if{ |task_id, movements| dups.include?(task_id) || movements['entry'].nil? || movements['exit'].nil? }
        end
      end
    
      def cycle_entry_movements
        # we enter the cycle 'from' column when the movement 'to' is that column
        Service::Insight::Storage::Movements.fetch_to(team_id: @team_id, board_id: @board_id, after: @after, before: @before, to: @named_cycle.entry)
      end

      def cycle_exit_movements
        # we exit the cycle 'to' column when the movement 'from' is that column
        Service::Insight::Storage::Movements.fetch_from(team_id: @team_id, board_id: @board_id,  after: @after, before: @before, from: @named_cycle.exit)
      end

      def dups
        @dups ||= []
      end
  
      def add_movements(hash:, movements:, action:)
        movements.each do |movement|
          hash[movement.task_id] ||= {}
          dups << movement.task_id if hash[movement.task_id][action]
          hash[movement.task_id][action] = movement
        end
      end
    end
  end
end
  