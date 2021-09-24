'storage/kanbanize/s3/task'

FactoryBot.define do

    factory :history_detail, class: "Storage::Kanbanize::HistoryDetail" do
      sequence(:historyid){|n| n.to_s }
      sequence(:taskid){|n| n.to_s }
      author{ Faker::Internet.username }
      eventtype{ "Transitions" }
      historyevent { "Task moved" }
      details { "From 'Test.ColA' to 'Test.ColB'" }
      entrydate { Time.now.strftime("%Y-%m-%d %H:%M:%S") }

      initialize_with{ Storage::Kanbanize::HistoryDetail.new(stringify_keys(attributes)) }
    end
  
  end
  