require 'handlers/recipes'
require 'service/recipes/controller'
require 'bot/event_builders'

describe 'handler' do

  let(:bot_request){ build(:bot_request, bot_event: bot_event) }
  let(:aws_records_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }
  
  context 'recipe search' do

    let(:bot_event){ Bot::EventBuilders.recipe_search_requested(source: :intent, query: 'beef rendang') }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 

  context 'favourites search' do

    let(:bot_event){ Bot::EventBuilders.favourite_search_requested(source: :intent) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 
  
  context 'favourites updated' do

    let(:bot_event){ Bot::EventBuilders.favourites_updated(source: :intent, favourite_recipe_ids: ['12345','45678']) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 
end

