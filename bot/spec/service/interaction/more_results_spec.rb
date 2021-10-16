require 'service/interaction/controller'
require 'topic/sns'
require 'gerty/request/event'
require 'gerty/request/events/recipes'

describe Service::Interaction::Controller do
  context 'more results' do

    let(:bot_request){  build(:slack_interaction_more_results_request) }

    it 'should broadcast the  event to the interactions topic' do
      expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a recipes next page search event' do
      allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['name']).to eq Gerty::Request::Events::Recipes::SEARCH_REQUESTED
    end

  end
end
