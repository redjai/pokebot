require 'bot/event'


FactoryBot.define do

  factory :bot_event_record, class: Bot::EventRecord do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ Bot::EventRecord.new(source: source, name: name, version: version, data: data) }
  end

  factory :bot_event, class: Bot::Event do
    transient do
      bot_event_record { build(:bot_event_record) }
    end

    slack_user {
       { 
          'slack_id' => 'UTESTSLACK123', 
          'channel' => 'CTESTSLACK234' 
       } 
    } 
    current { bot_event_record } 
    trail { [ build(:bot_event_record, data: {'fizz' => 'bang'}) ] }
    
    initialize_with{ Bot::Event.new(current: current, slack_user: slack_user, trail: trail) }
  end

end
