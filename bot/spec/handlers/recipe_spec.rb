require 'handlers/recipes'
require 'service/recipes/controller'
require 'bot/event_builders'

describe 'handler' do

  let(:bot_event){ build(:bot_event, bot_event_record: bot_event_record) }
  let(:aws_event){ build(:aws_event, bot_event: bot_event) }
  let(:context){ {} }
  
  context 'recipe search' do

    let(:bot_event_record){ Bot::EventBuilders.recipe_search_requested(source: :intent, query: 'beef rendang') }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Event))
      handle(event: aws_event, context: context)
    end

  end 

  context 'favourites search' do

    let(:bot_event_record){ Bot::EventBuilders.favourite_search_requested(source: :intent) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Event))
      handle(event: aws_event, context: context)
    end

  end 
  
  context 'favourites updated' do

    let(:bot_event_record){ Bot::EventBuilders.favourites_updated(source: :intent, favourite_recipe_ids: ['12345','45678']) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Bot::Event))
      handle(event: aws_event, context: context)
    end

  end 
end

