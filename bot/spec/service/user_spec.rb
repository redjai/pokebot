require 'service/user/controller'
require 'topic/sns'

describe Service::User::Controller do

  around do |example|
    DbSpec.create_table(table) 
    ClimateControl.modify FAVOURITES_TABLE_NAME: table, USER_TOPIC_ARN: 'abc-123' do
      example.run
    end
    DbSpec.delete_table(table)
  end

  let(:in_event){  current: build(:bot_event_record, :favourite_new, favourite: favourite)) }
  let(:table){ 'test-user-table' } 
  let(:favourite){ 234567 }

  context 'user does not exist' do
    
    before(:each) do
      allow(Topic::Sns).to receive(:broadcast)
    end
    
    it 'should create a new user item' do
      expect {
        subject.call(in_event)
      }.to change{ DbSpec.count('test-user-table') }.by(1)
    end
    
    context 'user item' do

      before(:each) do
        subject.call(in_event)
      end

      let(:item){ DbSpec.item(table, { user_id: in_event.data['user']['slack_id']} ) } 

      it 'set the slack_id as key' do
        expect(item['user_id']).to eq in_event.data['user']['slack_id'] 
      end

      it 'should create a set with the favourite' do
        expect(item['favourites']).to eq Set.new([in_event.data['favourite_id'].to_s]) 
      end

    end

  end

  context 'broadcast' do

    let(:source){ :user }
    let(:topic){ :user }
    let(:event_name){ Bot::Event::USER_FAVOURITES_UPDATED }
    let(:version){ 1.0 }
    let(:data){ 
      {
        favourites: [favourite.to_s],
        user: in_event.data['user']
      }
    }

    it 'should send the user favourite updated message' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: topic, source: source, name: event_name, version: version, event: in_event, data: data) 
      subject.call(in_event)
    end 

  end

  context 'user exists' do

    it 'should create a new user item' do
    end

    it 'should not create a new user item' do

    end

  end

  context 'favourite exists' do

    it 'should create a new user item' do
    end

    it 'should not create a new user item' do

    end

  end
end
