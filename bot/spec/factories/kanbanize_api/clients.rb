require 'storage/kanbanize/dynamodb/client'

FactoryBot.define do
  factory :client, class: Storage::Kanbanize::DynamoDB::Client do

    client_id { "test-client-1" }
    boards { ["11", "12", "13"] }

    initialize_with{ described_class.new(stringify_keys(attributes_for))  }

  end
end
