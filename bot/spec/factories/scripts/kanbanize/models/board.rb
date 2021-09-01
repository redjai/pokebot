FactoryBot.define do

  factory :board do
    id { Faker::Number.number }

    initialize_with{ Board.new(attributes) } 
  end

end