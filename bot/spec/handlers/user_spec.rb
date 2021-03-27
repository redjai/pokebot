require 'handlers/user'
require 'service/user/controller'
require 'topic/topic'

describe 'handler' do

  let(:bot_request){ build(:bot_request, :with_user_favourite_new) }
  let(:aws_records_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }

  it 'should call the controller with a bot event' do
    expect(Service::User::Controller).to receive(:call).with(kind_of(Topic::Request))
    User::Handler.handle(event: aws_records_event, context: context)
  end

end

