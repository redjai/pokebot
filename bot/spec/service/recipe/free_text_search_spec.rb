require 'service/recipe/controller'
require 'json'
require 'topic/sns'

describe Service::Recipe::Controller do


  context 'search' do

    context 'recipes found' do

      let(:bot_request){ build(:bot_request, :with_event_context, current: ::Request::Events::Recipes.search_requested(query: query, source: 'intent')) }
      let(:complex_search_uri){ 'https://api.spoonacular.com/recipes/complexSearch' }
      let(:query){ 'beef rendang' }
      let(:offset){ 0 }
      let(:per_page){ 10 }
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

      table!(:FAVOURITES_TABLE_NAME,'test-recipe-user-table')

      around do |example|
        ClimateControl.modify SPOONACULAR_API_KEY: api_key do
          example.run
        end 
      end

      before do
        allow(Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request) 
        stub_request(:get, complex_search_uri).with(query: { "apiKey" => api_key , "query" => query, "offset" => offset, "number" => per_page}).and_return(body: complex_search_response.to_json)
        stub_request(:get, information_bulk_uri).with(query: { "apiKey" => api_key , "ids" => ids }).and_return(body: information_bulk_response.to_json)
      end
      
      it 'should set the information_bulk data in the event as recipes' do
          subject.call(bot_request) 
          expect(bot_request.next.first[:current]['data']['recipes']).to eq information_bulk_response
      end

      context 'favourites' do

        let(:user_id){ bot_request.context.slack_id }
        let(:favourites){ ['123','456'] }

        it 'should return an empty list where the user does not exist' do
            subject.call(bot_request) 
            expect(bot_request.next.first[:current]['data']['favourite_recipe_ids']).to eq []
        end

        it 'should return the favourites as a list when the user does exist' do
            Service::Recipe::User.upsert(user_id, favourites)
            subject.call(bot_request) 
            expect(bot_request.next.first[:current]['data']['favourite_recipe_ids']).to eq favourites
        end
      end

      context 'query' do
        
        it 'should assign the query' do
             subject.call(bot_request) 
             expect(bot_request.next.first[:current]['data']['query']).to eq "beef rendang"
         end

      end

      context 'page' do

        it 'should assign  offset, per_page and total_results as the page object' do
             subject.call(bot_request) 
             expect(bot_request.next.first[:current]['data']['page']).to eq({"offset"=>0, "per_page"=>10, "total_results"=>15}) 
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

