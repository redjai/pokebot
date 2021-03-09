require 'handlers/recipes'
require 'service/recipes/controller'
require 'topic/events/recipes'
require 'topic/events/users'

describe 'handler' do

  let(:bot_request){ build(:bot_request, bot_event: bot_event) }
  let(:aws_records_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }
  
  context 'recipe search' do

    let(:bot_event){ Topic::Events::Recipes.search_requested(source: :intent, query: 'beef rendang') }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Topic::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 

  context 'favourites search' do

    let(:bot_event){ Topic::Events::Recipes.favourites_requested(source: :intent) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Topic::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 
  
  context 'favourites updated' do

    let(:bot_event){ Topic::Events::Users.favourites_updated(source: :intent, favourite_recipe_ids: ['12345','45678']) }

    it 'should call the controller with a bot event' do
      expect(Service::Recipe::Controller).to receive(:call).with(kind_of(Topic::Request))
      Recipes::Handler.handle(event: aws_records_event, context: context)
    end

  end 
end

