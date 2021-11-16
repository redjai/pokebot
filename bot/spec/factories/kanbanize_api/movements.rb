
require 'storage/kanbanize/dynamodb/tasks/movement'

FactoryBot.define do

  factory :movement, class: Storage::DynamoDB::Kanbanize::Tasks::Movement do
    team_id { "T12345" }
    board_id { "4" }
    history_detail { build(:history_detail, :movement) }

    initialize_with{ Storage::DynamoDB::Kanbanize::Tasks::Movement.new(team_id: team_id, board_id: board_id, history_detail: history_detail) }
  end

end