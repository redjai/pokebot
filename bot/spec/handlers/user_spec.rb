require 'handlers/user'
require 'service/user/controller'
require 'topic/events/users'

describe 'handler' do

  let(:bot_event){ Topic::Events::Users.favourite_new(source: :interactions, favourite_recipe_id: '12345') }
  let(:bot_request){ build(:bot_request, bot_event: bot_event) }
  let(:aws_records_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }

  it 'should call the controller with a bot event' do
    expect(Service::User::Controller).to receive(:call).with(kind_of(Topic::Request))
    User::Handler.handle(event: aws_records_event, context: context)
  end

end

