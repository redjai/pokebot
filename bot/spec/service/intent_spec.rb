require 'service/intent/controller'
require 'topic/sns'
require 'request/event'
require 'request/events/message'

describe Service::Intent::Controller do

  context 'recipe search' do

    let(:bot_request){ build(:bot_request, current: ::Request::Events::Messages.received(source: :messages, text: 'beef rendang')) }

    it 'sets the correct data' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.data }.from(bot_request.data).to({"query"=>"beef rendang", "page"=>{"offset"=>0, "per_page"=>10}})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.name }.from(::Request::Events::Messages::RECEIVED).to(::Request::Events::Recipes::SEARCH_REQUESTED)
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
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.data }.from(bot_request.data).to({offset: 0})
    end

    it 'set the correct event type' do
      allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      expect{ 
        subject.call(bot_request)
      }.to change { bot_request.name }.from(::Request::Events::Messages::RECEIVED).to(::Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED)
    end

    it 'should brodacast the event to the intent topic' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end

  end
end
