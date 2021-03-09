require 'handlers/responder'
require 'topic/events/recipes'
require 'topic/events/messages'
require 'service/responder/controller'

describe Responder::Handler do

  context 'recipes found' do

    let(:bot_record){ Topic::Events::Recipes.found(source: :recipes, complex_search: {}, information_bulk: {}, favourite_recipe_ids:[], query: {}) }
    let(:bot_request){ build(:bot_request, current: bot_record) }
    let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }

    it 'should call the service controller' do
      expect(Service::Responder::Controller).to receive(:call).with(kind_of(Topic::Request))
      Responder::Handler.handle(event: aws_event, context: {})
    end      

  end

  context 'message received' do

    let(:bot_record){ Topic::Events::Messages.received(source: :messages, text: 'hello world') }
    let(:bot_request){ build(:bot_request, current: bot_record) }
    let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }

    it 'should call the service controller' do
      expect(Service::Responder::Controller).to receive(:call).with(kind_of(Topic::Request))
      Responder::Handler.handle(event: aws_event, context: {})
    end      

  end
end
