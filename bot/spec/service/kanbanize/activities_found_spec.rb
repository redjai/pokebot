require 'service/kanbanize/controller'
require 'topic/sns'
require 'request/event'
require 'service/kanbanize/new_activities_found'
require 'storage/kanbanize/activity'

describe Service::Kanbanize::NewActivitiesFound do

  setup_s3!

  let(:bot_request){ build(:bot_request, :with_activities_imported) } 

  context 'no prior activities exist that day' do
    
    context 'saving s3 files' do
      let(:board_id){ bot_request.data['board_id'] }
      let(:client_id){ bot_request.data['client_id'] }
      let(:store){ Storage::Kanbanize::ActivityS3 }
      let(:activity1){ Storage::Kanbanize::ActivityData.new(client_id, board_id, bot_request.data['activities'].first) }
      let(:activity2){ Storage::Kanbanize::ActivityData.new(client_id, board_id, bot_request.data['activities'].last) }

      let(:found_activities){ {"client_id" => client_id, "activities" => [ activity1.data ], "board_id" => board_id } }

      before do
        allow(Topic::Sns).to receive(:broadcast).with(topic: [:kanbanize, :users], request: bot_request)
        SpecHelper::S3.bucket.object(activity2.key).put(body: activity2.to_json)
      end

      it 'should save the uncreated activity to s3' do
        expect {
          described_class.call(bot_request)
        }.to change{ SpecHelper::S3.exists?(activity1.key) }.from(false).to(true) 
      end

      it 'should broadcast only the created activity  to sns' do
        expect(Topic::Sns).to receive(:broadcast).with(topic: [:kanbanize, :users], request: bot_request).once
        described_class.call(bot_request)
      end
      
      it 'should NOT save the created activity to s3' do
        expect_any_instance_of(Aws::S3::Object).to receive(:put).with(body: bot_request.data['activities'].last.to_json).never
        described_class.call(bot_request)
      end

      it 'should change data' do
        expect{
          described_class.call(bot_request)
        }.to change{ bot_request.current['data'] }.from(bot_request.current['data']).to(found_activities) 
      end

      context 'no new activitoes' do

        before do
          allow_any_instance_of(Aws::S3::Object).to receive(:exists?).and_return(true)
          expect(Topic::Sns).to receive(:broadcast).never
        end

        it 'should not broadcast an event' do
          described_class.call(bot_request)
        end

      end
    end
  end
end
