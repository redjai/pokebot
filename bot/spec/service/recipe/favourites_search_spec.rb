require 'service/recipe/controller'
require 'json'
require 'topic/sns'
require 'service/recipe/user'
require 'topic/topic'

describe Service::Recipe::Controller do


  context 'search' do

    context 'recipes found' do

      let(:bot_request){ build(:bot_request, :with_event_context, current: Topic::Recipes.favourites_requested(source: 'intent')) }
      let(:offset){ 0 }
      let(:api_key){ 'mock-spoonacular-api-key' }
      let(:recipe_1){ '123' }
      let(:recipe_2){ '234' }
      let(:information_bulk_response){
        { 
          "mock_result" => 123
        }
      }
      let(:ids){ [recipe_1, recipe_2].join(",") }
      let(:information_bulk_uri){ 'https://api.spoonacular.com/recipes/informationBulk' }
      let(:table) { 'test-recipe-user-table' }

      table!('test-recipe-user-table')

      around do |example|
        ClimateControl.modify SPOONACULAR_API_KEY: api_key do
          example.run
        end 
      end

      before do
        allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request) 
        stub_request(:get, information_bulk_uri).with(query: { "apiKey" => api_key , "ids" => ids }).and_return(body: information_bulk_response.to_json)
      end

      context 'favourites' do
     
        context 'user favourites exist' do
          
          let(:user_id){ bot_request.context.slack_id }
          let(:favourites){ [recipe_1, recipe_2] }

          before do
            Service::Recipe::User.upsert(user_id, favourites)
          end

          it 'should set the information_bulk data in the event' do
              subject.call(bot_request) 
              expect(bot_request.data['recipes']).to eq information_bulk_response
          end
          
          it 'should set the recipe_ids list' do
              subject.call(bot_request) 
              expect(bot_request.data['favourite_recipe_ids']).to eq favourites
          end
        end
      end

      context 'no favourites exist' do

        it 'should set the information_bulk as an empty list' do
            subject.call(bot_request) 
            expect(bot_request.data['recipes']).to eq []
        end

        it 'should return an empty list where the user does not exist' do
            subject.call(bot_request) 
            expect(bot_request.data['favourite_recipe_ids']).to eq []
        end

      end

    end

    context 'recipes not found' do

      it 'should set empty recipes data in the event'

    end

    it 'should broadcast recipes to the recipes topic'
  end

  context 'recipes' do

  end

end

