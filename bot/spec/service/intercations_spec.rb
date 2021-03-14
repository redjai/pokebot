require 'service/interaction/controller'
require 'topic/sns'
require 'topic/events/slack'
require 'topic/event'

describe Service::Interaction::Controller do

  context 'favourites' do

    let(:aws_records_event){ build(:slack_favourites_interaction_event) }
    let(:bot_request){ Topic::Events::Slack.interaction_event(aws_records_event) }

    it 'should broadcast to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :users, event: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a favourites new event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :users, event: bot_request)
      subject.call(bot_request)
      expect(bot_request.name).to eq Topic::USER_FAVOURITE_NEW
    end

  end

  context 'more results' do

    let(:aws_records_event){ build(:slack_more_results_interaction_event) }
    let(:bot_request){ Topic::Events::Slack.interaction_event(aws_records_event) }

    it 'should broadcast the  event to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, event: bot_request)
      subject.call(bot_request)
    end
    
    it 'should broadcast a recipes next page search event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, event: bot_request)
      subject.call(bot_request)
      expect(bot_request.name).to eq Topic::RECIPE_SEARCH_REQUESTED
    end

  end
end
