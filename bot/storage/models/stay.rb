require 'date'

module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        class Cycle
          
          attr_accessor :team_id, :board_id, :task_id, :entry_history_detail_id, :exit_history_detail_id, :name, :entry_at, :exit_at

          def errors 
            @errors ||= []
          end

          def error_json
            item.merge({errors: errors})
          end

          def entry=(movement)
            errors << "entry cannot be later than exit" if @exit_at && @exit_at < movement.history_detail.entry_date
            @entry_at = movement.history_detail.entry_date
            paranoid_set(:entry_history_detail_id, movement.history_detail.history_detail_id)
            common(movement)
          end

          def exit=(movement)
            errors << "exit cannot be earlier than entry" if @entry_at && @entry_at > movement.history_detail.entry_date
            @exit_at = movement.history_detail.entry_date
            paranoid_set(:exit_history_detail_id, movement.history_detail.history_detail_id)
            common(movement)
          end

          def duration
            ((DateTime.parse(exit_at) - DateTime.parse(entry_at)) * 24.0).to_i if exit_at && entry_at
          end

          def item
            {
              id: id,
              team_board_id: "#{team_id}-#{board_id}",
              task_id: task_id,
              entry_history_detail_id: entry_history_detail_id,
              exit_history_detail_id: exit_history_detail_id,
              stay => name,
              entry_at: entry_at,
              exit_at: exit_at,
              duration: duration
            }
          end

          def valid?
            entry_history_detail_id && exit_history_detail_id && errors.empty?
          end

          protected

          def common(movement)
            paranoid_set(:team_id, movement.team_id)
            paranoid_set(:board_id, movement.board_id)
            paranoid_set(:task_id, movement.history_detail.task_id)
          end

          def paranoid_set(name, value)
            var = "@#{name}"
            existing = instance_variable_get(var)
            if existing && existing != value
              errors << "expected new value  for '#{name}=#{value}' to match existing '#{name}=#{existing}'"
            else
              instance_variable_set(var, value)
            end 
          end

          def id
            "#{team_id}-#{board_id}-#{entry_history_detail_id}-#{exit_history_detail_id}"
          end

        end

        # class ColumnStay < Stay

        #   def stay
        #     :column_stay
        #   end

        #   def entry=(movement)
        #     paranoid_set(:name, movement.to_name)
        #     super(movement)
        #   end

        #   def exit=(movement)
        #     paranoid_set(:name, movement.from_name)
        #     super(movement)
        #   end

        # end

        # class SectionStay < Stay

        #   def stay
        #     :section_stay
        #   end

        #   def entry=(movement)
        #     paranoid_set(:name, movement.to_section_name)
        #     super(movement)
        #   end

        #   def exit=(movement)
        #     paranoid_set(:name, movement.from_section_name)
        #     super(movement)
        #   end

        # end

      end
    end
  end
end