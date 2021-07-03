FactoryBot.define do

  factory :activity, class: Hash do
    sequence(:taskid){|n| n.to_s }
    author{ Faker::Internet.username }
    event { "Task moved" }
    text { "From 'Test.A 'to Test.Z'" }
    date { Time.now.strftime("%Y-%m-%d %H:%M:%S") }
    initialize_with{ stringify_keys(attributes) }
  end

end
