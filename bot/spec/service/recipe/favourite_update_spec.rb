require 'service/recipe/controller'

describe Service::Recipe::Controller do
  
  let(:slack_id){ 'test-slack-id-1234' }
  let(:context){ build(:block_actions_interaction_context, slack_id: slack_id) }
  let(:bot_request){ build(:bot_request, :with_event_context, :with_user_favourites_updated, context: context) }
  let(:table){ 'test-recipe-user-table' } 
  let(:favourites){ bot_request.data['favourite_recipe_ids']  }
  let(:item){ Service::Recipe::User.read bot_request.context.slack_id } 
  
  table!(:FAVOURITES_TABLE_NAME,'test-recipe-user-table')

  context 'user does not exist' do
    
    it 'should create a new user item' do
      expect {
        subject.call(bot_request)
      }.to change{ DbSpec.count(table) }.by(1)
    end
    
    it 'should set the favourite' do
      subject.call(bot_request)
      expect(item['favourites']).to eq favourites 
    end

    context 'user item' do

      before(:each) do
        subject.call(bot_request)
      end

      it 'set the slack_id as key' do
        expect(item['user_id']).to eq bot_request.context.slack_id 
      end

      it 'should create a set with the favourite' do
        expect(item['favourites']).to eq favourites
      end

    end

  end

  context 'user exists' do

    let(:existing_favourites){ previous_bot_request.data['favourite_recipe_ids'] }
    let(:slack_id){ 'test-slack-id-1234' }
    let(:context){ build(:block_actions_interaction_context, slack_id: slack_id) }
    let(:previous_bot_request){ build(:bot_request, :with_user_favourites_updated, context: context) }
    
    before(:each) do
      subject.call(previous_bot_request) # set up the user with a favourite
    end

    it 'should not create a new user item' do
      expect {
        subject.call(bot_request)
      }.to change{ DbSpec.count('test-recipe-user-table') }.by(0)
    end
      

    context 'favourites existing' do

      it 'should overwrite existing favourite with the updated list' do
        expect{
          subject.call(bot_request)
        }.to change { Service::Recipe::User.read(bot_request.context.slack_id)['favourites']  }.from(existing_favourites).to(favourites)
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
