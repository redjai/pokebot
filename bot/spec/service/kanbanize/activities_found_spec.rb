require 'service/kanbanize/controller'
require 'topic/sns'
require 'request/event'

describe Service::Kanbanize::BoardActivitiesImported do

  setup_s3!

  let(:bot_request){ build(:bot_request, :with_activities_imported) } 

  before do
    
  end

  context 'no prior activities exist that day' do
    
    context 'saving s3 files' do
      let(:board_id){ bot_request.data['board_id'] }
      let(:activity1){ Service::Kanbanize::Activity.new(board_id, bot_request.data['activities'].first) }
      let(:activity2){ Service::Kanbanize::Activity.new(board_id, bot_request.data['activities'].last) }

      let(:found_activities){ {"activities" => [ activity1.data ], "board_id" => board_id } }

      before do
        allow(Topic::Sns).to receive(:broadcast).with(topic: :kanbanize, request: bot_request)
        SpecHelper::S3.bucket.object(activity2.key).put(body: activity2.to_json)
      end

      it 'should save the uncreated activity to s3' do
        expect {
          described_class.call(bot_request)
        }.to change{ SpecHelper::S3.exists?(activity1.key) }.from(false).to(true) 
      end

      it 'should broadcast only the created activity  to sns' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: :kanbanize, request: bot_request).once
        described_class.call(bot_request)
      end
      
      it 'should NOT save the created activity to s3' do
        expect_any_instance_of(Service::Kanbanize::Activities).to receive(:store_activity).once
        described_class.call(bot_request)
      end

      it 'should change data' do
        expect{
          described_class.call(bot_request)
        }.to change{ bot_request.current['data'] }.from(bot_request.current['data']).to(found_activities) 
      end
    end
  end
end
