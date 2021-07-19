require 'handlers/kanbanize/cron'
require 'handlers/kanbanize/imports'
require 'service/kanbanize/new_activities_found'
require 'service/kanbanize/import_board_activities'
require 'service/kanbanize/import_tasks'


describe Kanbanize::Cron::Handler do

  let(:aws_event){ {'action' => 'kanbanize-import-activities'} }
  let(:context){ {} }

  it 'should call the kanbanize service controller' do
    expect(Service::Kanbanize::ImportBoardActivities).to receive(:call).with(::Request::Request)
    Kanbanize::Cron::Handler.handle(event: aws_event, context: context)
  end

end

describe Kanbanize::Imports::Handler do

  let(:aws_event){ build(:aws_records_event, bot_request: bot_request) }
  let(:context){ {} }

  context 'activitis imported' do

    let(:bot_request){ build(:bot_request, :with_activities_imported) } 
    
    it 'should call the kanbanize service controller' do
      expect(Service::Kanbanize::NewActivitiesFound).to receive(:call).with(::Request::Request)
      Kanbanize::Imports::Handler.handle(event: aws_event, context: context)
    end

  end

  context 'activities found' do

    let(:bot_request){ build(:bot_request, :with_new_activities_found) } 
    
    it 'should call the kanbanize service controller' do
      expect(Service::Kanbanize::ImportTasks).to receive(:call).with(::Request::Request)
      Kanbanize::Imports::Handler.handle(event: aws_event, context: context)
    end

  end
end

