require 'handlers/kanbanize/cron'
require 'handlers/kanbanize/sqs'
require 'service/kanbanize/new_activities_found'
require 'service/kanbanize/import_board_activities'


describe Kanbanize::Cron::Handler do

  let(:aws_event){ {'action' => 'kanbanize-import-activities'} }
  let(:context){ {} }

  it 'should call the kanbanize service controller' do
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:call).with(::Request::Request)
    Kanbanize::Cron::Handler.handle(event: aws_event, context: context)
  end

end

describe Kanbanize::Sqs::Handler do
  
  let(:bot_request){ build(:bot_request, :with_activities_imported) } 
  let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }

  it 'should call the kanbanize service controller' do
    expect(Service::Kanbanize::NewActivitiesFound).to receive(:call).with(::Request::Request)
    Kanbanize::Sqs::Handler.handle(event: aws_event, context: context)
  end

end

