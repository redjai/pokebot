require 'service/message/controller'
require 'topic/sns'
require 'bot/event_builders'
require 'bot/event'

describe Service::Message::Controller do

  let(:aws_records_event){ build(:slack_api_request_aws_event, text: "<USER> test message") }
  let(:bot_event){ Bot::EventBuilders.slack_api_event(aws_records_event) }

  it 'should strip the user from the slack message text and add it to the event' do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_event)
    expect{ 
      subject.call(bot_event)
    }.to change { bot_event.data }.from(bot_event.data).to({"text"=>"test message"})
  end
  
  it 'should update the event name to message received' do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_event)
    expect{ 
      subject.call(bot_event)
    }.to change { bot_event.name }.from(Bot::SLACK_EVENT_API_REQUEST).to(Bot::MESSAGE_RECEIVED)
  end

  it 'should broadcast the event to the messages topic' do
    expect(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_event)
    subject.call(bot_event)
  end
end
