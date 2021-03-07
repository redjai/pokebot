require 'service/interaction/controller'
require 'topic/sns'
require 'bot/event_builders'
require 'bot/event'

describe Service::Interaction::Controller do

  context 'favourites' do

    let(:aws_records_event){ build(:slack_favourites_interaction_event) }
    let(:bot_event){ Bot::EventBuilders.slack_interaction_event(aws_records_event) }

    it 'should broadcast to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :interactions, event: bot_event)
      subject.call(bot_event)
    end
    
    it 'should broadcast a favourites search event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :interactions, event: bot_event)
      subject.call(bot_event)
      expect(bot_event.name).to eq Bot::FAVOURITES_SEARCH_REQUESTED
    end

  end

  context 'more results' do

    let(:aws_records_event){ build(:slack_more_results_interaction_event) }
    let(:bot_event){ Bot::EventBuilders.slack_interaction_event(aws_records_event) }

    it 'should broadcast the  event to the interactions topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :interactions, event: bot_event)
      subject.call(bot_event)
    end
    
    it 'should broadcast a recipes next page search event' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :interactions, event: bot_event)
      subject.call(bot_event)
      expect(bot_event.name).to eq Bot::RECIPE_SEARCH_NEXT_PAGE
    end

  end
end
