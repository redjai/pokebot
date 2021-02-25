require 'bot/event'


FactoryBot.define do
  factory :bot_event_record, class: Bot::EventRecord do
    source { :test_source }
    name { :test_name }
    version { 1.0 }
    data { { 'foo' => 1, 'bar' => 2 } }

    transient do
      favourite { 12345 }
    end

    trait :favourite_new do
       name { Bot::Event::FAVOURITE_NEW }

        data {
          { 'favourite_id' => favourite, 
            'user' => { 
              'slack_id' => 'UTESTSLACK123', 
              'channel' => 'CTESTSLACK234' 
            } 
          }
       }
    end

    initialize_with{ new(source: source, name: name, version: version, data: data) }
  end
  
  factory :bot_event, class: Bot::Event do
    initialize_with{ new(current: current) }
  end

end
