require 'slack/response'
require 'service/responder/controller'

describe Service::Responder::Controller do

  context 'recipes found' do

    let(:bot_request){ build(:bot_request, :with_recipes_found) }
    let(:channel){ bot_request.slack_user['channel'] }
    let(:text){ 'recipes:' }

    it 'should respond to slack' do
      expect(Slack::Response).to receive(:respond).with(channel: channel, text: text, blocks: instance_of(Array), response_url: nil)
      subject.call(bot_request)
    end

  end

  context 'favourites found' do

    let(:bot_request){ build(:bot_request, :with_favourites_found) }
    let(:channel){ bot_request.slack_user['channel'] }
    let(:text){ 'recipes:' }

    it 'should respond to slack' do
      expect(Slack::Response).to receive(:respond).with(channel: channel, text: text, blocks: instance_of(Array), response_url: nil)
      subject.call(bot_request)
    end

  end

  context 'message received' do

    let(:bot_request){ build(:bot_request, :with_message_received) }
    let(:channel){ bot_request.slack_user['channel'] }
    let(:text){ ":smiley:  _some test text_...\n...helping you is what I do !" }

    it 'should respond to slack' do
      expect(Slack::Response).to receive(:respond).with(channel: channel, text: text)
      subject.call(bot_request)
    end
  end
  
  context 'favourites updated' do

    let(:bot_request){ build(:bot_request, :with_user_favourites_updated) }
    let(:channel){ bot_request.slack_user['channel'] }
    let(:favourites_count){ bot_request.data['favourite_recipe_ids'].length }
    let(:text){ "favourites updated, you have #{favourites_count} favourites. You can see them with the shortcut /favourites" }

    it 'should respond to slack' do
      expect(Slack::Response).to receive(:respond).with(channel: channel, text: text)
      subject.call(bot_request)
    end
  end
end
