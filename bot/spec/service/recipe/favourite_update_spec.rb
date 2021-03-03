require 'bot/event_builders'
require 'service/recipes/controller'

describe Service::Recipe::Controller do
  
  let(:bot_event){ build(:bot_event, current: Bot::EventBuilders.favourites_updated(source: :users, favourite_recipe_ids:  favourites)) }
  let(:table){ 'test-recipe-user-table' } 
  let(:favourites){ ["234567","678910"] }
  let(:item){ Service::Recipe::User.read bot_event.slack_user['slack_id'] } 
  
  table!('test-recipe-user-table')

  context 'user does not exist' do
    
    it 'should create a new user item' do
      expect {
        subject.call(bot_event)
      }.to change{ DbSpec.count(table) }.by(1)
    end
    
    it 'should set the favourite' do
      subject.call(bot_event)
      expect(item['favourites']).to eq favourites 
    end

    context 'user item' do

      before(:each) do
        subject.call(bot_event)
      end

      it 'set the slack_id as key' do
        expect(item['user_id']).to eq bot_event.slack_user['slack_id'] 
      end

      it 'should create a set with the favourite' do
        expect(item['favourites']).to eq favourites
      end

    end

  end

  context 'user exists' do

    let(:existing_favourites){ ["987654"] }
    let(:previous_bot_event){ build(:bot_event, current: Bot::EventBuilders.favourites_updated(source: :user, favourite_recipe_ids:  existing_favourites)) }
    
    before(:each) do
      subject.call(previous_bot_event) # set up the user with a favourite
    end

    it 'should not create a new user item' do
      expect {
        subject.call(bot_event)
      }.to change{ DbSpec.count('test-recipe-user-table') }.by(0)
    end
      

    context 'favourites existing' do

      it 'should overwrite existing favourite with the updated list' do
        expect{
          subject.call(bot_event)
        }.to change { Service::Recipe::User.read(bot_event.slack_user['slack_id'])['favourites']  }.from(existing_favourites).to(favourites)
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
