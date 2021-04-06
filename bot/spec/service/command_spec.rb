require 'service/command/controller'
require 'topic/topic'

describe Service::Command::Controller do

  before do
    allow(Topic::Sns).to receive(:broadcast)
  end
  
  context 'favourites' do

    let(:aws_event){ build(:slack_command_favourite_aws_event) }
    let(:bot_request){ Topic::Slack.command_request(aws_event) }


    it 'should call favourites' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :recipes, event: bot_request)
      subject.call(bot_request)
    end
    
    it 'should emit a favourite requested event' do
      expect{ 
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Topic::Slack::SHORTCUT_API_REQUEST).to(Topic::Recipes::FAVOURITES_SEARCH_REQUESTED) 
    end

  end

  context 'account' do

    let(:aws_event){ build(:slack_command_account_aws_event) }
    let(:bot_request){ Topic::Slack.command_request(aws_event) }

    it 'should call favourites' do
      expect(Topic::Sns).to receive(:broadcast).with(topic: :users, event: bot_request)
      subject.call(bot_request)
    end
    
    it 'should emit an account edit event' do
      expect{ 
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Topic::Slack::SHORTCUT_API_REQUEST).to(Topic::Users::ACCOUNT_SHOW_REQUESTED) 
    end
  end

end
