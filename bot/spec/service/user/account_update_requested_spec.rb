require 'request/events/users'
require 'service/user/controller'
require 'topic/sns'
require 'service/user/storage'

describe Service::User::Controller do

  let(:table){ 'test-user-table' } 
  let(:user){ Service::User::Storage.read bot_request.context.slack_id } 
  let(:handle){ bot_request.data['handle'] }
  let(:email){ bot_request.data['email'] }
  let(:kanbanize_username){ bot_request.data['kanbanize_username'] }
  let(:bot_request){ build(:bot_request, :with_event_context, :with_user_account_update_requested) }
  
  table!(:FAVOURITES_TABLE_NAME,'test-user-table')
  
  context 'update requested' do

    context 'user does not exist' do

      before(:each) do
        allow(Topic::Sns).to receive(:broadcast)
      end
      
      it 'should broadcast to the user topic' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
        subject.call(bot_request)
      end

      it 'should create an account update event' do
        subject.call(bot_request)
        expect(bot_request.next.first[:current]['name']).to eq ::Request::Events::Users::ACCOUNT_UPDATED
      end  

      it 'should create a new  user' do
        expect {
          subject.call(bot_request)
        }.to change{ DbSpec.count('test-user-table') }.by(1)
      end

      it 'should create a user with handle' do
        subject.call(bot_request)
        expect(user['handle']).to eq handle
      end

      it 'should create a user with no kanbanize username' do
        subject.call(bot_request)
        expect(user['kanbanize_username']).to eq kanbanize_username
      end
      
      it 'should create a user with email' do
        subject.call(bot_request)
        expect(user['email']).to eq email
      end
    end
    
    context 'user exists' do

      let(:old_handle){ Faker::Name.name }
      let(:old_email){ Faker::Internet.email }
      let(:old_kanbanize_username){ Faker::Internet.username }

      before(:each) do
        allow(Topic::Sns).to receive(:broadcast)
        Service::User::Storage.update_account(slack_id: bot_request.context.slack_id, email: old_email, handle: old_handle, kanbanize_username: old_kanbanize_username)
      end
      
      it 'should broadcast to the user topic' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
        subject.call(bot_request)
      end

      it 'should create an account update event' do
        subject.call(bot_request)
        expect(bot_request.next.first[:current]['name']).to eq ::Request::Events::Users::ACCOUNT_UPDATED
      end  

      it 'should not create a user' do
        expect {
          subject.call(bot_request)
        }.to change{ DbSpec.count('test-user-table') }.by(0)
      end

      it 'should update the existing  handle' do
        subject.call(bot_request)
        expect(user['handle']).to eq handle
      end
      
      it 'should update the existing  kanbanize username' do
        subject.call(bot_request)
        expect(user['kanbanize_username']).to eq kanbanize_username
      end
      
      it 'should update the existing email' do
        subject.call(bot_request)
        expect(user['email']).to eq email
      end
    end
  end
end
