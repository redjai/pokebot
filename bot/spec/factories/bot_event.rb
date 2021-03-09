require 'topic/event'


FactoryBot.define do

  factory :bot_event, class: Topic::Event do

    source { :test_source }
    name { 'test-event-name' }
    version { 1.0 }
    data { { 'foo' => 'bar' } }

    initialize_with{ Topic::Event.new(source: source, name: name, version: version, data: data) }
  end

  factory :bot_request, class: Topic::Request do
    transient do
      bot_event { build(:bot_event) }
    end

    slack_user {
       { 
          'slack_id' => 'UTESTSLACK123', 
          'channel' => 'CTESTSLACK234' 
       } 
    } 
    current { bot_event } 
    trail { [ build(:bot_event, data: {'fizz' => 'bang'}) ] }
    
    initialize_with{ Topic::Request.new(current: current, slack_user: slack_user, trail: trail) }
  end

end
