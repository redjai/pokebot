require 'service/intent/controller'
require 'topic/sns'
require 'bot/event'
require 'bot/event_builders'

describe Service::Intent::Controller do

  context 'recipe search' do

    let(:bot_request){ build(:bot_request, current: Bot::EventBuilders.message_received(source: :messages, text: 'beef rendang')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.data }.from(bot_request.data).to({"query"=>"beef rendang", "offset" => 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.name }.from(Bot::MESSAGE_RECEIVED).to(Bot::RECIPE_SEARCH_REQUESTED)
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      subject.call(bot_request)
    end

  end

  context 'favourite search' do
    
    let(:bot_request){ build(:bot_request, current: Bot::EventBuilders.message_received(source: :messages, text: 'favourite')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.data }.from(bot_request.data).to({offset: 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.name }.from(Bot::MESSAGE_RECEIVED).to(Bot::FAVOURITES_SEARCH_REQUESTED)
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :intent, event: bot_request)
      subject.call(bot_request)
    end

  end
end
