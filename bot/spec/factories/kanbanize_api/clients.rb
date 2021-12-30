require 'storage/dynamodb/team'

FactoryBot.define do
  factory :client, class: Storage::DynamoDB::Team do

    team_id { "test-client-1" }
    boards { ["11", "12", "13"] }

    initialize_with{ described_class.new(stringify_keys(attributes_for))  }

  end
end
