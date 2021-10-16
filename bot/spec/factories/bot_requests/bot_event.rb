require 'gerty/request/event'

FactoryBot.define do

  factory :bot_event, class: ::Gerty::Request::Event do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ Gerty::Request::Event.new(source: source, name: name, version: version, data: data) }

  end

end