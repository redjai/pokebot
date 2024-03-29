require 'gerty/request/events/users'
require 'service/user/controller'
require 'topic/sns'
require 'service/user/storage'

describe Service::User::Controller do

  let(:table){ 'test-user-table' } 
  let(:user){ Service::User::Storage.read bot_request.context.slack_id } 
  
  table!(:FAVOURITES_TABLE_NAME,'test-user-table')
  
  context 'edit requested' do

    let(:bot_request){ build(:bot_request, :with_event_context, :with_user_account_edit_requested) }

    context 'user does not exist' do

      before(:each) do
        allow(Gerty::Topic::Sns).to receive(:broadcast)
      end
      
      it 'should broadcast to the user topic' do
        expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
        subject.call(bot_request)
      end

      it 'should create an account update event' do
        subject.call(bot_request)
        expect(bot_request.next.first[:current]['name']).to eq Gerty::Request::Events::Users::ACCOUNT_READ
      end  

      it 'should not create a new  user' do
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
    
    context 'user exists' do

      before(:each) do
        allow(Gerty::Topic::Sns).to receive(:broadcast)
        Service::User::Storage.update_account(slack_id: bot_request.context.slack_id, email: nil, handle: nil, kanbanize_username: nil)
      end
      
      it 'should broadcast to the user topic' do
        expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
        subject.call(bot_request)
      end

      it 'should create an account update event' do
          subject.call(bot_request)
          expect(bot_request.next.first[:current]['name']).to eq Gerty::Request::Events::Users::ACCOUNT_READ
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
