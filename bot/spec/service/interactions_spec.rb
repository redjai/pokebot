require 'service/interaction/controller'
require 'topic/sns'
require 'topic/topic'
require 'topic/event'
require 'topic/topic'

describe Service::Interaction::Controller do

  context 'user_update_requested' do
    let(:slack_interaction_event){ build(:slack_interaction_user_update_requested) }
  
    it "should broadcast a user update requested event to the users topic" do
      #puts slack_interaction_event.inspect
    end
  end

  context 'favourites' do

    let(:aws_records_event){ build(:slack_favourites_interaction_aws_event) }
    let(:bot_request){ Topic::Slack.interaction_request(aws_records_event) }

    it 'should broadcast to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a favourites new event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.name).to eq Topic::Users::FAVOURITE_NEW
    end

  end

  context 'more results' do

    let(:aws_records_event){ build(:slack_more_results_interaction_aws_event) }
    let(:bot_request){ Topic::Slack.interaction_request(aws_records_event) }

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
