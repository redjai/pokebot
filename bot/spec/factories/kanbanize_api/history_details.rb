require 'storage/kanbanize/dynamodb/tasks/history_detail'


FactoryBot.define do

    factory :api_history_detail, class: Hash do
      sequence(:historyid){|n| n.to_s }
      sequence(:taskid){|n| n.to_s }
      author{ Faker::Internet.username }
      eventtype{ "Transitions" }
      historyevent { "Task moved" }
      details { Faker::Lorem.paragraph }
      entrydate { Time.now.strftime("%Y-%m-%d %H:%M:%S") }

      initialize_with{ stringify_keys(attributes) }
    end

    trait :column_movement do
      details { "From 'Test.ColA' to 'Test.ColB'" }
    end
  
  end

  FactoryBot.define do

    factory :history_detail, class: Storage::DynamoDB::Kanbanize::Tasks::HistoryDetail do

      team_id { "T12345" }
      kanbanize_data { build(:api_history_detail) }

      initialize_with{ Storage::DynamoDB::Kanbanize::Tasks::HistoryDetail.new(team_id: team_id, kanbanize_data: kanbanize_data) }

      trait :movement do
        kanbanize_data { build(:api_history_detail, :column_movement) }
      end

    end

  end

  FactoryBot.define do

    factory :api_board_column, class: Hash do
      sequence(:position) { |n| n.to_s }
      sequence(:lcname) { |n| "Column#{n}" }
      sequence(:section) { |n| "section#{n}" }
      path{ "backlog_306" } 
      description { Faker::Lorem.paragraph }
      lcid { "306" }
      flowtype { "queue" }
      tasksperrow { 2 }

      initialize_with{ stringify_keys(attributes) }

      trait :with_children do

        after(:build) do |column, evaluator|
          column['children'] = [ build(:api_board_column), build(:api_board_column),  build(:api_board_column)]
        end

      end

    end

  end
  