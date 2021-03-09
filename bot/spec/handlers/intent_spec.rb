require 'handlers/intent'
require 'service/intent/controller'
require 'topic/events/messages'

describe 'handler' do

  let(:bot_event){ Topic::Events::Messages.received(source: :messages, text: 'beef rendang') }
  let(:bot_request){ build(:bot_request, bot_event: bot_event) }
  let(:aws_records_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }

  it 'should call the controller with a bot event' do
    expect(Service::Intent::Controller).to receive(:call).with(kind_of(Topic::Request))
    Intent::Handler.handle(event: aws_records_event, context: context)
  end

end

