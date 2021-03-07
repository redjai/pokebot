require 'service/message/controller'
require 'bot/topic/sns'
require 'bot/event_builders'
require 'bot/event'

describe Service::Message::Controller do

  let(:aws_records_event){ build(:slack_api_request_aws_event, text: "<USER> test message") }
  let(:bot_request){ Bot::EventBuilders.slack_api_event(aws_records_event) }

  it 'should strip the user from the slack message text and add it to the event' do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_request)
    expect{ 
      subject.call(bot_request)
    }.to change { bot_request.data }.from(bot_request.data).to({"text"=>"test message"})
  end
  
  it 'should update the event name to message received' do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_request)
    expect{ 
      subject.call(bot_request)
    }.to change { bot_request.name }.from(Bot::SLACK_EVENT_API_REQUEST).to(Bot::MESSAGE_RECEIVED)
  end

  it 'should broadcast the event to the messages topic' do
    expect(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_request)
    subject.call(bot_request)
  end
end
