
require 'handlers/test'
require 'request/events/topic'

describe Test::Handler do

  let(:aws_event){ }
  let(:context){ }

  it 'should' do
    Test::Handler.handle(event: aws_event, context: context)
  end

end
