require 'service/kanbanize/controller'
require 'topic/sns'
require 'request/event'


describe Service::Kanbanize::ImportBoardActivities do

  table!(:KANBANIZE_CLIENTS_TABLE_NAME, 'test-clients-table') 

  let(:client_id) { bot_request.data['client_id'] }

  let!(:kanbanize_client){ described_class.create_client(client_id, ["11","12","17"]) ; described_class.get_client(client_id) }

  let(:from_date){ (Date.today - 1).strftime("%Y-%m-%d")  }
  let(:to_date){ (Date.today).strftime("%Y-%m-%d")  }

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
    ClimateControl.modify KANBANIZE_SUBDOMAIN: 'test-subdomain', KANBANIZE_API_KEY: 'test-api-key', PAGE_SIZE: "2" do
      example.run
    end
  end

  before do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :kanbanize, request: bot_request)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body1).and_return(response_1)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body2).and_return(response_2)
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:post).with(uri: uri, body: body3).and_return(response_3)
  end

  context 'pagination' do

    it 'should call the kanbanize activities endpoint for each page' do
      described_class.call(bot_request) 
    end

  end

  context 'aggregated results' do

    it 'should aggregate all activities' do
      described_class.call(bot_request)
      expect(bot_request.data['activities']).to eq activities 
    end

    it 'should include board_id' do
      described_class.call(bot_request)
      expect(bot_request.data['board_id']).to eq kanbanize_client.board_id 
    end
  end

  it 'should persist the board id as the last board id' do
    expect(described_class.get_client(client_id).last_board_id).not_to eq kanbanize_client.board_id
    described_class.call(bot_request)
    expect(described_class.get_client(client_id).last_board_id).to eq kanbanize_client.board_id
  end

end
