require 'handlers/user'
require 'service/user/controller'
require 'bot/event_builders'

describe 'handler' do

  let(:bot_event_record){ Bot::EventBuilders.favourite_new(source: :interactions, favourite_recipe_id: '12345') }
  let(:bot_event){ build(:bot_event, bot_event_record: bot_event_record) }
  let(:aws_records_event){ build(:aws_records_event, bot_event: bot_event) }
  let(:context){ {} }

  it 'should call the controller with a bot event' do
    expect(Service::User::Controller).to receive(:call).with(kind_of(Bot::Event))
    User::Handler.handle(event: aws_records_event, context: context)
  end

end

