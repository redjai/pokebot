require 'service/bounded_context'

describe Service::BoundedContext do

  before do
    require 'spec/support/bounded_contexts/test_bounded_context/test_service_1.rb'
    require 'spec/support/bounded_contexts/test_bounded_context/test_service_2.rb'
  end

  subject{ described_class }

  context '::register' do

    let(:listens_1){ TestService1.listen.collect{|name| name.to_sym } }
    let(:broadcasts_1){ TestService1.broadcast.collect{|name| name.to_sym } }

    let(:listens_2){ TestService2.listen.collect{|name| name.to_sym } }
    let(:broadcasts_2){ TestService2.broadcast.collect{|name| name.to_sym } }


    it 'should register the listen and broadcast for service 1 as symbols' do
      expect(described_class.listens[TestService1]).to eq listens_1
      expect(described_class.broadcasts[TestService1]).to eq broadcasts_1
    end

    it 'should register the listen and broadcast for service 2' do
      expect(described_class.listens[TestService2]).to eq listens_2
      expect(described_class.broadcasts[TestService2]).to eq broadcasts_2
    end
    
  end

  context '::call' do

    let(:bot_request_1){ build(:bot_request, bot_event: event_1a) }
    let(:bot_request_2){ build(:bot_request, bot_event: event_2b) }
    let(:event_1a){ build(:bot_event, name: 'test_event_1a') }
    let(:event_2b){ build(:bot_event, name: 'test_event_2b') }

    it 'should call test service 1 with test_event_1a and broadcast' do
      expect(TestService1).to receive(:call).with(bot_request_1).and_call_original
      expect(Topic::Sns).to receive(:broadcast).with(topic: :test_topic_1a, request: bot_request_1)
      expect(Topic::Sns).to receive(:broadcast).with(topic: :test_topic_1b, request: bot_request_1)
      expect(TestService2).to receive(:call).never
      subject.call(bot_request_1)
    end

    it 'should call test service 2 with test_event_1a and broadcast' do
      expect(TestService2).to receive(:call).with(bot_request_2).and_call_original
      expect(Topic::Sns).to receive(:broadcast).with(topic: :test_topic_2a, request: bot_request_2)
      expect(Topic::Sns).to receive(:broadcast).with(topic: :test_topic_2b, request: bot_request_2)
      expect(TestService2).to receive(:call).never
      subject.call(bot_request_2)
    end

    context 'the service does not broadcast the bot_request if no event has been added' do
      
      # don't use .and_call_original so bot request is not updated by service
      it 'should not broadcast' do
        expect(TestService1).to receive(:call).with(bot_request_1) 
        expect(Topic::Sns).to receive(:broadcast).never
        expect(Topic::Sns).to receive(:broadcast).never
        expect(TestService2).to receive(:call).never
        subject.call(bot_request_1)
      end
    end

  end

end