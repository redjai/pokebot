require 'topic/topic'
require 'service/user/controller'
require 'topic/sns'

describe Service::User::Controller do

  let(:bot_request){ build(:bot_request, :with_user_account_edit) }
  let(:table){ 'test-user-table' } 
  let(:item){ Service::User::Account.read bot_request.slack_user['slack_id'] } 
  
  table!('test-user-table')

  context 'user does not exist' do

    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
    end
    
    it 'should broadcast to the user topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :users, event: bot_request) 
      subject.call(bot_request)
    end

    it 'should create an account update event' do
      expect{
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Topic::Users::ACCOUNT_EDIT).to(Topic::Users::ACCOUNT_UPDATE)
    end  

    it 'should create a new user item' do
      expect {
        subject.call(bot_request)
      }.to change{ DbSpec.count('test-user-table') }.by(1)
    end

    it 'should create a user with no handle' do
      subject.call(bot_request)
      expect(bot_request.data['handle']).to be_nil
    end

    it 'should create a user with no kanbanize username' do
      subject.call(bot_request)
      expect(bot_request.data['kanbanize_username']).to be_nil
    end
  end
  
  context 'user exists' do

    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
      Service::User::Account.upsert(bot_request.slack_user['slack_id'], nil, nil)
    end
    
    it 'should broadcast to the user topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :users, event: bot_request) 
      subject.call(bot_request)
    end

    it 'should create an account update event' do
      expect{
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Topic::Users::ACCOUNT_EDIT).to(Topic::Users::ACCOUNT_UPDATE)
    end  

    it 'should create a new user item' do
      expect {
        subject.call(bot_request)
      }.to change{ DbSpec.count('test-user-table') }.by(0)
    end

    it 'should create a user with no handle' do
      subject.call(bot_request)
      expect(bot_request.data['handle']).to be_nil
    end

    it 'should create a user with no kanbanize username' do
      subject.call(bot_request)
      expect(bot_request.data['kanbanize_username']).to be_nil
    end
  end
end
