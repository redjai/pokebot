require 'service/intent/controller'
require 'topic/sns'
require 'request/event'
require 'request/events/messages'

describe Service::Intent::Controller do

  context 'recipe search' do

    let(:bot_request){ build(:bot_request, current: ::Request::Events::Messages.received(source: :messages, text: 'beef rendang')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['data']).to eq({"query"=>"beef rendang", "page"=>{"offset"=>0, "per_page"=>10}})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['name']).to eq ::Request::Events::Recipes::SEARCH_REQUESTED
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end

  end

  context 'favourite search' do
    
    let(:bot_request){ build(:bot_request, current: ::Request::Events::Messages.received(source: :messages, text: 'favourite')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['data']).to eq({offset: 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
      expect(bot_request.next.first[:current]['name']).to eq Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end

  end
end
