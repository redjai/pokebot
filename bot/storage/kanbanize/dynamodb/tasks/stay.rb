

module Storage
  module DynamoDB
    module Kanbanize
      module Tasks
        class Stay
          
          attr_accessor :team_id, :board_id, :task_id, :entry_history_detail_id, :exit_history_detail_id, :name, :entry_at, :exit_at, :type

          def entry=(movement)
            raise ArgumentError.new("entry cannot be later than exit") if @exit_at && @exit_at < movement.history_detail.entrydate
            @entry_at = movement.history_detail.entrydate
            paranoid_set(:entry_history_detail_id, movement.history_detail.id)
            common(movement)
          end

          def exit=(movement)
            raise ArgumentError.new("exit cannot be earlier than entry") if @entry_at && @entry_at > movement.history_detail.entrydate
            @exit_at = movement.history_detail.entrydate
            paranoid_set(:exit_history_detail_id, movement.history_detail.id)
            common(movement)
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
              raise ArgumentError.new("expected new value #{value} for #{name} to equal existing value but found #{existing}")
            end 
            instance_variable_set(var, value)
          end

        end

        class ColumnStay < Stay

          def entry=(movement)
            paranoid_set(:name, movement.to_name)
            super(movement)
          end

          def exit=(movement)
            paranoid_set(:name, movement.from_name)
            super(movement)
          end

        end
      end
    end
  end
end