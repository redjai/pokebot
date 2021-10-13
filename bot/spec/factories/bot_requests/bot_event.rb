require 'request/event'

FactoryBot.define do

  factory :bot_event, class: ::Request::Event do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ ::Request::Event.new(source: source, name: name, version: version, data: data) }

  end

end