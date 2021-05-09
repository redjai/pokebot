require 'service/interaction/controller'
require 'topic/sns'
require 'topic/topic'
require 'topic/event'
require 'topic/topic'

describe Service::Interaction::Controller do
  context 'more results' do

    let(:bot_request){  build(:slack_interaction_more_results_request) }

    it 'should broadcast the  event to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a recipes next page search event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.name).to eq Topic::Recipes::SEARCH_REQUESTED
    end

  end
end
