require 'service/intent/controller'
require 'topic/sns'
require 'bot/event_builders'
require 'bot/event'

describe Service::Intent::Controller do

  context 'recipe search' do

    let(:bot_event){ build(:bot_event, current: Bot::EventBuilders.message_received(source: :messages, text: 'beef rendang')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      expect{ 
        subject.call(bot_event)
      }.to change { bot_event.data }.from(bot_event.data).to({"query"=>"beef rendang", "offset" => 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      expect{ 
        subject.call(bot_event)
      }.to change { bot_event.name }.from(Bot::MESSAGE_RECEIVED).to(Bot::RECIPE_SEARCH_REQUESTED)
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      subject.call(bot_event)
    end

  end

  context 'favourite search' do
    
    let(:bot_event){ build(:bot_event, current: Bot::EventBuilders.message_received(source: :messages, text: 'favourite')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      expect{ 
        subject.call(bot_event)
      }.to change { bot_event.data }.from(bot_event.data).to({offset: 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      expect{ 
        subject.call(bot_event)
      }.to change { bot_event.name }.from(Bot::MESSAGE_RECEIVED).to(Bot::FAVOURITES_SEARCH_REQUESTED)
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_event)
      subject.call(bot_event)
    end

  end
end
