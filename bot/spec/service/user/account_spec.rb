require 'topic/topic'
require 'service/user/controller'
require 'topic/sns'
require 'service/user/storage'

describe Service::User::Controller do

  let(:table){ 'test-user-table' } 
  let(:user){ Service::User::Storage.read bot_request.slack_user['slack_id'] } 
  
  table!('test-user-table')

  context 'Requested and Found' do

    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
    end
    
    let(:bot_request){ build(:bot_request, :with_user_account_requested) }


    context 'user does not exist' do

      it 'should' do
        subject.call(bot_request)
      end

      it 'should change the event from requested to found' do
        expect{
          subject.call(bot_request)
        }.to change { bot_request.name }.from(Topic::Users::ACCOUNT_REQUESTED).to(Topic::Users::ACCOUNT_FOUND)
      end

      it 'should set nil user data' do
        subject.call(bot_request)
        expect(bot_request.data).to eq( { 'user' =>  Service::User::Storage.nil_user })
      end

    end

    context 'user exists' do

      before(:each) do
        Service::User::Storage.update_account(bot_request.slack_user['slack_id'], nil, nil)
      end

      it 'should change the event from requested to found' do
        expect{
          subject.call(bot_request)
        }.to change { bot_request.name }.from(Topic::Users::ACCOUNT_REQUESTED).to(Topic::Users::ACCOUNT_FOUND)
      end
      
      it 'should set the found user data' do
        subject.call(bot_request)
        expect(bot_request.data).to eq({ 'user' => user })
      end
    end

  end

  context 'Edit & Update' do

    let(:bot_request){ build(:bot_request, :with_user_account_edit) }

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

      it 'should create a new user user' do
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
        Service::User::Storage.update_account(bot_request.slack_user['slack_id'], nil, nil)
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

      it 'should create a new user user' do
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
end
