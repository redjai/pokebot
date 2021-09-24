require 'scripts/kanbanize/models/task_action'

FactoryBot.define do

  factory :task_action do
 
    entry_at{ Time.now - 48 * 3600 }
    exit_at{ Time.now - 3600 }
    entry_history_event{ 'Task moved' }
    exit_history_event{ 'Task moved' }

    initialize_with{ TaskAction.new(
      entry_at: entry_at,
      exit_at: exit_at,
      entry_history_event: entry_history_event,
      exit_history_event: exit_history_event)
    }
  end

end