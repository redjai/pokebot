require 'gerty/request/events/users'
require 'service/user/controller'
require 'topic/sns'

describe Service::User::Controller do

  let(:slack_id){ 'test-slack-id-1234' }
  let(:context){ build(:block_actions_interaction_context, slack_id: slack_id) } # ensures a consistent slack id for users in the spec
  let(:bot_request){ build(:bot_request, context: context, current: Gerty::Request::Events::Users.favourite_new(source: :interactions, favourite_recipe_id:  favourite)) }
  let(:table){ 'test-user-table' } 
  let(:favourite){ "234567" }
  let(:item){ Service::User::Storage.read bot_request.context.slack_id } 
  
  table!(:FAVOURITES_TABLE_NAME,'test-user-table')

  context 'recipes' do

    context 'user does not exist' do
      
      before(:each) do
        allow(Gerty::Topic::Sns).to receive(:broadcast)
      end
      
      
      it 'should create a new user item' do
        expect {
          subject.call(bot_request)
        }.to change{ DbSpec.count('test-user-table') }.by(1)
      end
      
      it 'should set the favourite' do
        subject.call(bot_request)
        expect(item['favourites']).to eq Set.new([favourite]) 
      end

      it 'should broadcast the user favourites array to the users topic' do
        expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
        subject.call(bot_request)
      end

      context 'user item' do

        before(:each) do
          subject.call(bot_request)
        end

        it 'set the slack_id as key' do
          expect(item['user_id']).to eq bot_request.context.slack_id 
        end

        it 'should create a set with the favourite' do
          expect(item['favourites']).to eq Set.new([favourite]) 
        end

      end

    end

    context 'user exists' do

      let(:existing_favourite){ "987654" }
      let(:previous_context){ build(:block_actions_interaction_context, slack_id: slack_id) } # ensures a consistent slack id for users in the spec
      let(:previous_bot_request){ build(:bot_request, context: previous_context, current: Gerty::Request::Events::Users.favourite_new(source: :interactions, favourite_recipe_id:  existing_favourite)) }
      
      before(:each) do
        allow(Gerty::Topic::Sns).to receive(:broadcast)
        subject.call(previous_bot_request) # set up the user with a favourite
      end

      it 'should not create a new user item' do
        expect {
          subject.call(bot_request)
        }.to change{ DbSpec.count('test-user-table') }.by(0)
      end
        

      context 'favourite does not exist' do

        it 'should append the favourite if it doesnt exist' do
          subject.call(bot_request)
          expect(item['favourites']).to eq Set.new([favourite, existing_favourite]) 
        end

        it 'should broadcast the user favourites array to the users topic' do
          expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
          subject.call(bot_request)
        end

      end

      context 'favourite does exist' do

        it 'should NOT append the favourite if it doesnt exist' do
          subject.call(previous_bot_request)
          expect(item['favourites']).to eq Set.new([existing_favourite]) 
        end

        it 'should NOT broadcast the user favourites array to the users topic' do
          expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request).never
          subject.call(previous_bot_request)
        end
      end
    end
  end
end
