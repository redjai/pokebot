require 'service/kanbanize/api'
require 'service/kanbanize/client'

FactoryBot.define do
  factory :clienti, class: Service::Kanbanize::Storage::Client do

    client_id { "test-client-1" }
    boards { ["11", "12", "13"] }

    initialize_with{ described_class.new(stringify_keys(attributes_for))  }

  end
end
