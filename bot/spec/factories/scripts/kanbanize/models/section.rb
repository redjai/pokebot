FactoryBot.define do

  factory :section do
    id { Faker::App.name }
    initialize_with { Section.new(attributes) } 
  end

end