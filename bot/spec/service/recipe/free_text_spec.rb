require 'service/recipes/controller'
require 'bot/event_builders' 
require 'json'
require 'topic/sns'

describe Service::Recipe::Controller do


  context 'search' do

    context 'recipes found' do

      let(:bot_event){ build(:bot_event, current: Bot::EventBuilders.recipe_search_requested(query: query, source: 'intent')) }
      let(:complex_search_uri){ 'https://api.spoonacular.com/recipes/complexSearch' }
      let(:query){ 'beef rendang' }
      let(:offset){ 0 }
      let(:api_key){ 'mock-spoonacular-api-key' }
      let(:recipe_1){ 123 }
      let(:recipe_2){ 234 }
      let(:complex_search_response){
        { 
          "totalResults" => 15,
          "results" => [{"id" => recipe_1},{"id" => recipe_2}] 
        }
      }
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
        allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, event: bot_event) 
        stub_request(:get, complex_search_uri).with(query: { "apiKey" => api_key , "query" => query, "offset" => offset }).and_return(body: complex_search_response.to_json)
        stub_request(:get, information_bulk_uri).with(query: { "apiKey" => api_key , "ids" => ids }).and_return(body: information_bulk_response.to_json)
      end

      it 'should set the complex_search data in the event' do
          subject.call(bot_event) 
          expect(bot_event.data['complex_search']).to eq complex_search_response
      end
      
      it 'should set the information_bulk data in the event' do
          subject.call(bot_event) 
          expect(bot_event.data['information_bulk']).to eq information_bulk_response
      end

      context 'favourites' do

        let(:user_id){ bot_event.slack_user['slack_id'] }
        let(:favourites){ ['123','456'] }

        it 'should return an empty list where the user does not exist' do
            subject.call(bot_event) 
            expect(bot_event.data['favourite_recipe_ids']).to eq []
        end

        it 'should return the favourites as a list when the user does exist' do
            Service::Recipe::User.upsert(user_id, favourites)
            subject.call(bot_event) 
            expect(bot_event.data['favourite_recipe_ids']).to eq favourites
        end
      end

      context 'query' do
        
        it 'should assign the query' do
             subject.call(bot_event) 
             expect(bot_event.data['query']).to eq({:offset=>0, :query=>"beef rendang"}) 
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

