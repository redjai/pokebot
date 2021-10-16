require 'service/kanbanize/controller'
require 'topic/sns'
require 'gerty/request/event'
require 'service/kanbanize/import_tasks'
require 'storage/kanbanize/s3/task'

describe Service::Kanbanize::ImportTasks do

  setup_s3!
  table!(:KANBANIZE_CLIENTS_TABLE_NAME, 'test-clients-table') 

  let(:bot_request){ build(:bot_request, :with_new_activities_found) } 
  
  let(:kanbanize_api_key){ 'test-api-key' }
  let(:subdomain){ 'test-subdomain' }
  let!(:kanbanize_client){ described_class.create_client(client_id, ["11","12","17"], kanbanize_api_key, subdomain) ; described_class.get_client(client_id) }

  let(:board_id){ bot_request.data['board_id'] }
  let(:client_id){ bot_request.data['client_id'] }
  let(:body){ { history: 'yes', board_id: bot_request.data['board_id'], taskid: task_id } } 
  let(:uri){ URI("https://test-subdomain.kanbanize.com/index.php/api/kanbanize/get_task_details/") }

  let(:task1){ {'taskid' => "1", "task" => "stuff"} }
  let(:key1){ Storage::Kanbanize::TaskData.new(client_id: client_id, board_id: board_id, task: task1).key }

  around(:each) do |example|
    ClimateControl.modify KANBANIZE_SUBDOMAIN: subdomain, KANBANIZE_API_KEY: kanbanize_api_key, PAGE_SIZE: "2" do
      example.run
    end
  end

  before do
    allow(Topic::Sns).to receive(:broadcast).with(topic: :kanbanize, request: bot_request)
    expect(Service::Kanbanize::ImportTasks).to receive(:post).with(uri: uri, body: body, kanbanize_api_key: kanbanize_api_key).and_return(response)
  end
  
  context 'calling tasks' do
    
    let(:response){ [ task1, task2 ] }
    let(:task_id){ bot_request.data['activities'].collect{|act| act['taskid'] } }  
    let(:task2){ {'taskid' => "2", "task" => "more stuff"}}
    let(:key2){ Storage::Kanbanize::TaskData.new(client_id: client_id, board_id: board_id, task: task2).key }
    
    context 'saving s3 files' do

      it 'should save the tasks to s3' do
        expect {
          described_class.call(bot_request)
        }.to change{ SpecHelper::S3.exists?(key1) }.from(false).to(true) 
      end
      
      it 'should save the tasks to s3' do
        expect {
          described_class.call(bot_request)
        }.to change{ SpecHelper::S3.exists?(key2) }.from(false).to(true) 
      end
      
    end
  end
end
