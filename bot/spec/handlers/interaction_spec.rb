require 'handlers/interactions'

describe Interactions::Handler do

  let(:aws_event){ build(:aws_event_slack_interaction_favourite_recipe) }

  it 'should' do
    expect(Service::Interaction::Controller).to receive(:call).with(kind_of(Topic::Request))
    Interactions::Handler.handle(event: aws_event, context: {}) 
  end 

end
