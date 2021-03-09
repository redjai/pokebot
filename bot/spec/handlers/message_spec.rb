require 'handlers/messages'
require 'service/message/controller'

describe 'message handler' do

  context 'slack challenge' do

    let(:challenge){ 'test-slack-challenge' }
    let(:aws_event){ build(:slack_challenge_event, challenge: challenge) }
    let(:context){ {} }
    let(:response){  {:body=>challenge, :headers=>{"Content-Type"=>"text/plain"}, :statusCode=>200 } }

    it 'should only return a challenge HTTP response' do
      expect(Messages::Handler.handle(event: aws_event, context: context)).to eq response
    end

    it 'should not call the controller' do
      expect(Service::Message::Controller).to receive(:call).never
    end

  end

  context 'slack authentication' do

    let(:aws_event){ build(:slack_recipe_search_event) }
    let(:context){ {} }
    let(:response){ {:body=>"Not authorized", :headers=>{"Content-Type"=>"text/plain"}, :statusCode=>401} }

    before do
      allow(Slack::Authentication).to receive(:authenticated?).and_return(false)
    end

    it 'should return a 401 HTTP response' do
      expect(Messages::Handler.handle(event: aws_event, context: context)).to eq response
    end

    it 'should not call the controller' do
      expect(Service::Message::Controller).to receive(:call).never
      Messages::Handler.handle(event: aws_event, context: context)
    end

  end

  context 'broadcast the event if no challenge and authnticated' do

    let(:aws_event){ build(:slack_recipe_search_event) }
    let(:context){ {} }
    
    before do
      allow(Slack::Authentication).to receive(:authenticated?).and_return(true)
    end
    
    it 'should not call the controller' do
      expect(Service::Message::Controller).to receive(:call).with(kind_of(Topic::Request))
      Messages::Handler.handle(event: aws_event, context: context)
    end
  end 
end
