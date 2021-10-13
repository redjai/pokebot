require 'handlers/processors/sqs_event'
require 'spec/factories/fixtures/aws_events/sqs/app_mention'

describe Handlers::SqsEvent do

  let(:aws_event){ Fixtures::AwsEvents.app_mention }
  subject{ described_class.new aws_event }

  let(:arn){ aws_event['Records'].first['eventSourceARN'] }

  it 'should return the first record event source arn' do
    expect(subject.event_source_arn).to eq arn
  end

  it 'should return an array of bot_requets' do
    expect(subject.bot_requests.first).to be_a(Request::Request)
    expect(subject.bot_requests.first.name).to eq 'app_mention'
  end

end