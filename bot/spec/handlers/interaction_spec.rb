require 'handlers/interactions'

describe Interactions::Handler do

  let(:aws_event){ build(:slack_favourites_interaction_aws_event) }

  it 'should' do
    expect(Service::Interaction::Controller).to receive(:call).with(kind_of(Topic::Request))
    Interactions::Handler.handle(event: aws_event, context: {}) 
  end 

end
