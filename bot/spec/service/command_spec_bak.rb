require 'service/command/controller'
require 'gerty/request/events/slack'
require 'gerty/request/events/recipes'

describe Service::Command::Controller do

  before do
    allow(Gerty::Topic::Sns).to receive(:broadcast)
  end
  
  context 'favourites' do

    let(:aws_event){ build(:slack_command_favourite_aws_event) }
    let(:bot_request){ Gerty::Request::Events::Slack.command_request(aws_event) }


    it 'should call favourites' do
      expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :recipes, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should emit a favourite requested event' do
      expect{ 
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Gerty::Request::Events::Slack::SHORTCUT_API_REQUEST).to(Gerty::Request::Events::Recipes::FAVOURITES_SEARCH_REQUESTED) 
    end

  end

  context 'account' do

    let(:aws_event){ build(:slack_command_account_aws_event) }
    let(:bot_request){ Gerty::Request::Events::Slack.command_request(aws_event) }

    it 'should call favourites' do
      expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request)
      subject.call(bot_request)
    end
    
    it 'should emit an account edit event' do
      expect{ 
        subject.call(bot_request)
      }.to change{ bot_request.name }.from(Gerty::Request::Events::Slack::SHORTCUT_API_REQUEST).to(Gerty::Request::Events::Users::ACCOUNT_SHOW_REQUESTED) 
    end
  end

end
