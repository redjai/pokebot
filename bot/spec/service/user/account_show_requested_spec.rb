require 'request/events/user'
require 'service/user/controller'
require 'topic/sns'
require 'service/user/storage'

describe Service::User::Controller do

  let(:table){ 'test-user-table' } 
  let(:user){ Service::User::Storage.read bot_request.context.slack_id } 
  
  table!('test-user-table')

  context 'user requests account show' do

    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
    end
    
    let(:bot_request){ build(:bot_request, :with_event_context, :with_user_account_show_requested) }

    context 'user does not exist' do

      it 'should' do
        subject.call(bot_request)
      end

      it 'should change the event from requested to found' do
        expect{
          subject.call(bot_request)
        }.to change { bot_request.name }.from(::Request::Events::Users::ACCOUNT_SHOW_REQUESTED).to(::Request::Events::Users::ACCOUNT_READ)
      end

      it 'should set nil user data' do
        subject.call(bot_request)
        expect(bot_request.data).to eq( { 'user' =>  Service::User::Storage.nil_user })
      end

    end

    context 'user exists' do

      before(:each) do
        Service::User::Storage.update_account(slack_id: bot_request.context.slack_id, email: nil, kanbanize_username: nil, handle: nil)
      end

      it 'should change the event from requested to found' do
        expect{
          subject.call(bot_request)
        }.to change { bot_request.name }.from(::Request::Events::Users::ACCOUNT_SHOW_REQUESTED).to(::Request::Events::Users::ACCOUNT_READ)
      end
      
      it 'should set the found user data' do
        subject.call(bot_request)
        expect(bot_request.data).to eq({ 'user' => user })
      end
    end
  end
end
