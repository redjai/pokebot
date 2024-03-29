require 'handlers/command'
require 'service/command/controller'

describe Command::Handler do

  context 'favourites' do

    let(:aws_event){ build(:slack_command_favourite_aws_event) }
    let(:bot_request){ Gerty::Request::Events::Slack.command_request(aws_event) }

    it 'should call favourites' do
      expect(Service::Command::Controller).to receive(:call).with(Gerty::Request::Request)
      described_class.handle(event: aws_event, context: {})
    end
  end

  context 'account' do

    let(:aws_event){ build(:slack_command_account_aws_event) }
    let(:bot_request){ Gerty::Request::Events::Slack.command_request(aws_event) }

    it 'should call favourites' do
      expect(Service::Command::Controller).to receive(:call).with(Gerty::Request::Request)
      described_class.handle(event: aws_event, context: {})
    end
  end
end
