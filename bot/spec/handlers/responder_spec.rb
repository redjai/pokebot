require 'handlers/responder'
require 'topic/topic'
require 'topic/topic'
require 'service/responder/controller'

describe Responder::Handler do

  context 'recipes found' do

    let(:bot_request){ build(:bot_request, :with_recipes_found) }
    let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }

    it 'should call the service controller' do
      expect(Service::Responder::Controller).to receive(:call).with(kind_of(Topic::Request))
      Responder::Handler.handle(event: aws_event, context: {})
    end      

  end

  context 'favourites found' do

    let(:bot_request){ build(:bot_request, :with_favourites_found) }
    let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }

    it 'should call the service controller' do
      expect(Service::Responder::Controller).to receive(:call).with(kind_of(Topic::Request))
      Responder::Handler.handle(event: aws_event, context: {})
    end      

  end

  context 'message received' do

    let(:bot_request){ build(:bot_request, :with_message_received) }
    let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }

    it 'should call the service controller' do
      expect(Service::Responder::Controller).to receive(:call).with(kind_of(Topic::Request))
      Responder::Handler.handle(event: aws_event, context: {})
    end      

  end
end
