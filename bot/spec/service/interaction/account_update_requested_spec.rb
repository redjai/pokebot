require 'topic/topic'
require 'service/interaction/controller'
require 'topic/sns'

describe Service::Interaction::Controller do

  let(:bot_request){ build(:slack_interaction_user_account_update_request) }

  it 'should broadcast a user account update requested to the users topic' do
    expect(Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
    subject.call(bot_request)
  end

end
