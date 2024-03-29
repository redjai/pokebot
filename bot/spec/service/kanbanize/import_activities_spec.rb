require 'service/kanbanize/controller'
require 'topic/sns'
require 'gerty/request/event'
require 'service/kanbanize/import_board_activities'

describe Service::Kanbanize::ImportBoardActivities do

  table!(:KANBANIZE_TEAMS_TABLE_NAME, 'test-clients-table') 

  let(:team_id) { bot_request.data['team_id'] }
  let(:kanbanize_api_key){ 'test-api-key' }
  let(:subdomain){ 'test-subdomain' }

  let!(:kanbanize_client){ described_class.create_client(team_id, ["11","12","17"], kanbanize_api_key, subdomain) ; described_class.get_team(team_id) }

  let(:from_date){ (Date.today).strftime("%Y-%m-%d")  }
  let(:to_date){ (Date.today + 1).strftime("%Y-%m-%d")  }

  let(:bot_request){ build(:bot_request, :with_kanbanize_import_transition_activities) } 
  let(:response_1){ { "allactivities" => "6", "page" => "1", "activities" => [build(:activity), build(:activity)] } }
  let(:response_2){ { "allactivities" => "6", "page" => "2", "activities" => [build(:activity), build(:activity)] } }
  let(:response_3){ { "allactivities" => "6", "page" => "3", "activities" => [build(:activity), build(:activity)] } }

  let(:uri){ URI("https://test-subdomain.kanbanize.com/index.php/api/kanbanize/get_board_activities/") }

  let(:body1){ {:boardid=> kanbanize_client.board_id, :eventtype=>"Transitions",:fromdate=>from_date,:page=>1, :resultsperpage=>"2",:todate=>to_date } }
  let(:body2){ {:boardid=> kanbanize_client.board_id, :eventtype=>"Transitions",:fromdate=>from_date,:page=>2, :resultsperpage=>"2",:todate=>to_date } }
  let(:body3){ {:boardid=> kanbanize_client.board_id, :eventtype=>"Transitions",:fromdate=>from_date,:page=>3, :resultsperpage=>"2",:todate=>to_date } }

  let(:activities){ 
    (response_1['activities'] + response_2['activities'] + response_3['activities']).flatten
  }

  around(:each) do |example|
    ClimateControl.modify KANBANIZE_SUBDOMAIN: subdomain, KANBANIZE_API_KEY: kanbanize_api_key, PAGE_SIZE: "2" do
      example.run
    end
  end

  before do
    allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :kanbanize, request: bot_request)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body1, kanbanize_api_key: kanbanize_api_key).and_return(response_1)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body2, kanbanize_api_key: kanbanize_api_key).and_return(response_2)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body3, kanbanize_api_key: kanbanize_api_key).and_return(response_3)
  end

  context 'pagination' do

    it 'should call the kanbanize activities endpoint for each page' do
      described_class.call(bot_request) 
    end

  end

  context 'aggregated results' do

    it 'should aggregate all activities' do
      described_class.call(bot_request)
      expect(bot_request.next.first[:current]['data']['activities']).to eq activities 
    end

    it 'should include board_id' do
      described_class.call(bot_request)
      expect(bot_request.next.first[:current]['data']['board_id']).to eq kanbanize_client.board_id 
    end
  end

  it 'should persist the board id as the last board id' do
    expect(described_class.get_team(team_id).last_board_id).not_to eq kanbanize_client.board_id
    described_class.call(bot_request)
    expect(described_class.get_team(team_id).last_board_id).to eq kanbanize_client.board_id
  end

end
