require 'service/message/controller'
require 'topic/sns'
require 'gerty/request/events/slack'
require 'gerty/request/events/messages'
require 'gerty/request/event'

describe Service::Message::Controller do

  let(:aws_records_event){ build(:slack_api_request_aws_event, text: "<USER> test message") }
  let(:bot_request){ Gerty::Request::Events::Slack.api_request(aws_records_event) }

  it 'should strip the user from the slack message text and add it to the event' do
    allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :messages, request: bot_request)
    subject.call(bot_request)
    expect(bot_request.next.first[:current]['data']).to eq ({"text"=>"test message"})
  end
  
  it 'should update the event name to message received' do
    allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :messages, request: bot_request)
    subject.call(bot_request)
    expect(bot_request.next.first[:current]['name']).to eq Gerty::Request::Events::Messages::RECEIVED
  end

  it 'should broadcast the event to the messages topic' do
    expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :messages, request: bot_request)
    subject.call(bot_request)
  end
end
