require 'service/message/controller'
require 'topic/sns'
require 'topic/topic'
require 'topic/event'

describe Service::Message::Controller do

  let(:aws_records_event){ build(:slack_api_request_aws_event, text: "<USER> test message") }
  let(:bot_request){ Topic::Slack.api_event(aws_records_event) }

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
    }.to change { bot_request.name }.from(Topic::Slack::EVENT_API_REQUEST).to(Topic::Messages::RECEIVED)
  end

  it 'should broadcast the event to the messages topic' do
    expect(Topic::Sns).to receive(:broadcast).with(topic: :messages, event: bot_request)
    subject.call(bot_request)
  end
end
