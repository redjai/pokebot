require 'service/interaction/controller'
require 'topic/sns'

describe Service::Interaction::Controller do

  let(:bot_request){ build(:slack_interaction_user_account_update_request) }

  it 'should broadcast a user account update requested to the users topic' do
    expect(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
    subject.call(bot_request)
  end

  context 'payload data' do

    before do
      allow(Gerty::Topic::Sns).to receive(:broadcast).with(topic: :users, request: bot_request) 
      subject.call(bot_request)
    end

    let(:event){ build(:slack_interaction_user_account_update_event) }
    let(:values){ event.record['data']['view']['state']['values'] }
    let(:email){ values["p6C"]["edit-email"]["value"] }
    let(:name){ values['AFnCV']['edit-handle']['value'] }
    let(:kanbanize){ values['6y0']['edit-kanbanize']['value'] }

    it 'should extract the email from the view submission' do
      expect(bot_request.next.first[:current]['data']['email']).to eq email 
    end
    
    it 'should extract the name from the view submission' do
      expect(bot_request.next.first[:current]['data']['handle']).to eq name 
    end

    it 'should extract the kanbanize from the view submission' do
      expect(bot_request.next.first[:current]['data']['kanbanize_username']).to eq kanbanize 
    end
  end

end
