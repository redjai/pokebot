require 'handlers/kanbanize'
require 'service/kanbanize/controller'


describe Kanbanize::Handler do

  let(:aws_event){ {'action' => 'test-action'} }
  let(:context){ }

  it 'should call the kanbanize service controller' do
    expect(Service::Kanbanize::Controller).to receive(:call).with(::Request::Request)
    Kanbanize::Handler.handle(event: aws_event, context: context)
  end

end
