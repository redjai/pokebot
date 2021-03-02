require 'bot/event_builders'
require 'service/user/controller'
require 'topic/sns'

describe Service::User::Controller do

  let(:bot_event){ build(:bot_event, current: Bot::EventBuilders.favourite_new(source: :interactions, favourite_recipe_id:  favourite)) }
  let(:table){ 'test-user-table' } 
  let(:favourite){ "234567" }
  let(:item){ Service::User::User.read bot_event.slack_user['slack_id'] } 
  
  table!('test-user-table')

  context 'user does not exist' do
    
    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
    end
    
    
    it 'should create a new user item' do
      expect {
        subject.call(bot_event)
      }.to change{ DbSpec.count('test-user-table') }.by(1)
    end
    
    it 'should set the favourite' do
      subject.call(bot_event)
      expect(item['favourites']).to eq Set.new([favourite]) 
    end

    it 'should broadcast the user favourites array to the users topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :user, event: bot_event)
      subject.call(bot_event)
    end

    context 'user item' do

      before(:each) do
        subject.call(bot_event)
      end

      it 'set the slack_id as key' do
        expect(item['user_id']).to eq bot_event.slack_user['slack_id'] 
      end

      it 'should create a set with the favourite' do
        expect(item['favourites']).to eq Set.new([favourite]) 
      end

    end

  end

  context 'user exists' do

    let(:existing_favourite){ "987654" }
    let(:previous_bot_event){ build(:bot_event, current: Bot::EventBuilders.favourite_new(source: :interactions, favourite_recipe_id:  existing_favourite)) }
    
    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
      subject.call(previous_bot_event) # set up the user with a favourite
    end

    it 'should not create a new user item' do
      expect {
        subject.call(bot_event)
      }.to change{ DbSpec.count('test-user-table') }.by(0)
    end
      

    context 'favourite does not exist' do

      it 'should append the favourite if it doesnt exist' do
        subject.call(bot_event)
        expect(item['favourites']).to eq Set.new([favourite, existing_favourite]) 
      end

      it 'should broadcast the user favourites array to the users topic' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: :user, event: bot_event)
        subject.call(bot_event)
      end

    end

    context 'favourite does exist' do

      it 'should NOT append the favourite if it doesnt exist' do
        subject.call(previous_bot_event)
        expect(item['favourites']).to eq Set.new([existing_favourite]) 
      end

      it 'should NOT broadcast the user favourites array to the users topic' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: :user, event: bot_event).never
        subject.call(previous_bot_event)
      end
    end
  end

  context 'favourite exists' do

    it 'should create a new user item' do
    end

    it 'should not create a new user item' do

    end

  end
end
