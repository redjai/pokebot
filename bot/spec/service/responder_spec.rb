require 'service/responder/slack/response'
require 'service/responder/controller'

describe Service::Responder::Controller do

  context 'recipes found' do

    let(:bot_request){ build(:bot_request, :with_recipes_found) }
    let(:channel){ bot_request.context.channel }
    let(:text){ 'recipes:' }

    it 'should respond to slack' do
      expect(Service::Responder::Slack::Response).to receive(:respond).with(channel: channel, text: text, blocks: instance_of(Array), response_url: nil)
      subject.call(bot_request)
    end

  end

  context 'favourites found' do

    let(:bot_request){ build(:bot_request, :with_favourites_found) }
    let(:channel){ bot_request.context.channel }
    let(:text){ 'recipes:' }

    it 'should respond to slack' do
      expect(Service::Responder::Slack::Response).to receive(:respond).with(channel: channel, text: text, blocks: instance_of(Array), response_url: nil)
      subject.call(bot_request)
    end

  end

  context 'message received' do

    let(:bot_request){ build(:bot_request, :with_message_received) }
    let(:channel){ bot_request.context.channel }
    let(:text){ ":smiley:  _some test text_...\n...helping you is what I do !" }

    it 'should respond to slack' do
      expect(Service::Responder::Slack::Response).to receive(:respond).with(channel: channel, text: text)
      subject.call(bot_request)
    end
  end
  
  context 'favourites updated' do

    let(:bot_request){ build(:bot_request, :with_user_favourites_updated) }
    let(:channel){ bot_request.context.channel }
    let(:favourites_count){ bot_request.data['favourite_recipe_ids'].length }
    let(:text){ "favourites updated, you have #{favourites_count} favourites. You can see them with the command /favourites" }

    it 'should respond to slack' do
      expect(Service::Responder::Slack::Response).to receive(:respond).with(channel: channel, text: text)
      subject.call(bot_request)
    end
  end
  
  context 'account read' do

    let(:channel){ bot_request.context.channel }
    let(:text){ "your account:" }

    context 'account show intent' do

      let(:bot_request){ build(:bot_request, :with_user_account_read, :with_account_show_intent) }
      
      it 'should respond to slack' do
        expect(Service::Responder::Slack::Response).to receive(:respond).with(channel: channel, text: text, blocks: kind_of(Array))
        subject.call(bot_request)
      end

    end
    
    context 'account edit requested' do

      let(:bot_request){ build(:bot_request,  :with_user_account_read, trail: [ build(:user_account_edit_requested).to_h ]) }
      let(:trigger_id){ bot_request.context.trigger_id }

      it 'should respond to slack' do
        expect(Service::Responder::Slack::Response).to receive(:delete).with(channel: bot_request.context.channel, ts: bot_request.context.message_ts)
        expect(Service::Responder::Slack::Response).to receive(:modal).with(trigger_id, kind_of(Hash))
        subject.call(bot_request)
      end

    end
  end
end
