require 'service/interaction/controller'
require 'topic/sns'
require 'gerty/request/event'

describe Service::Interaction::Controller do

  context 'favourites' do

    let(:bot_request){ build(:slack_interaction_favourite_recipe_request) }

    it 'should broadcast to the interactions topic' do
      expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a favourites new event' do
      allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['name']).to eq Gerty::Request::Events::Users::FAVOURITE_NEW
    end

  end

end
