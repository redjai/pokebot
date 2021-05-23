require 'topic/event'
require 'topic/base'

describe Topic::SlackContext do

  context 'to and from h' do
    let(:channel){ 'test-channel' } 
    let(:message_ts){ 'test-ts'} 
    let(:response_url){ 'test-response_url' } 
    let(:slack_id){ 'test-slack_id' } 
    let(:trigger_id){ 'test-trigger' }
    let(:to_h){ 
      {
        'channel' => channel, 
        'message_ts' => message_ts, 
        'response_url' => response_url, 
        'slack_id' => slack_id, 
        'trigger_id' => trigger_id
      }
    }

    context 'to_h' do

      subject{ Topic::SlackContext.new(slack_id: slack_id, 
                                        channel: channel, 
                                     message_ts: message_ts, 
                                     trigger_id: trigger_id,
                                   response_url: response_url)  }

      it 'should export to a hash' do
        expect(subject.to_h).to eq to_h
      end

    end

    context 'from_h' do
      subject{ Topic::SlackContext.from_h(to_h) }

      it 'should assign slack_id' do
        expect(subject.slack_id).to eq slack_id
      end

    end

  end

  context 'slash command' do

    subject{ described_class.from_slack_command(command_event) }
    let(:command_event){ build(:slack_command_user_account_show_requested_event) }
    let(:slack_id){ command_event.record['data']['user_id'].first }
    let(:channel){ command_event.record['data']['channel_id'].first }
    let(:response_url){ command_event.record['data']['response_url'].first }

    it 'should populate the context' do
      expect(subject.slack_id).to eq slack_id
    end

    it 'should populate the context channel' do
      expect(subject.channel).to eq channel
    end
    
    it 'should populate the context response_url' do
      expect(subject.response_url).to eq response_url 
    end

    it 'should not assign a message_ts' do
      expect(subject.message_ts).to be_nil 
    end

    it 'should not assign a trigger_id' do
      expect(subject.trigger_id).to be_nil 
    end

  end 
  
  context 'slack event' do

    subject{ described_class.from_slack_event(slack_event) }
    let(:slack_event){ build(:slack_event_api_recipe_search_event) }
    let(:slack_id){ slack_event.record['data']['event']['user'] }
    let(:channel){ slack_event.record['data']['event']['channel'] }

    it 'should populate the context' do
      expect(subject.slack_id).to eq slack_id
    end

    it 'should populate the context channel' do
      expect(subject.channel).to eq channel
    end
    
    it 'should not populate the context response_url' do
      expect(subject.response_url).to be_nil 
    end

    it 'should not assign a message_ts' do
      expect(subject.message_ts).to be_nil 
    end

    it 'should not assign a trigger_id' do
      expect(subject.trigger_id).to be_nil 
    end

  end 
  
  context 'slack interaction' do

    subject{ described_class.from_slack_interaction(interaction_event) }
    
    context 'block_actions' do

      let(:interaction_event){ build(:slack_interaction_favourite_recipe_event) }
      let(:slack_id){ interaction_event.record['data']['user']['id'] }
      let(:channel){ interaction_event.record['data']['container']['channel_id'] }
      let(:response_url){ interaction_event.record['data']['response_url'] }
      let(:trigger_id){ interaction_event.record['data']['trigger_id'] }
      let(:message_ts){ interaction_event.record['data']['container']['message_ts'] } 

      it 'should populate the context slack_id' do
        expect(subject.slack_id).to eq slack_id
      end

      it 'should populate the context channel' do
        expect(subject.channel).to eq channel
      end
      
      it 'should populate the context response_url' do
        expect(subject.response_url).to eq response_url 
      end

      it 'should assign a message_ts' do
        expect(subject.message_ts).to eq message_ts 
      end

      it 'should assign a trigger_id' do
        expect(subject.trigger_id).to eq trigger_id
      end

    end

    context 'view submissions' do

      let(:interaction_event){ build(:slack_interaction_user_account_update_event) }
      let(:private_metadata){ JSON.parse(interaction_event.record['data']['view']['private_metadata']) }
      let(:slack_id){ interaction_event.record['data']['user']['id'] }
      let(:response_url){ interaction_event.record['data']['response_url'] }
      let(:trigger_id){ interaction_event.record['data']['trigger_id'] }

      it 'should populate the context slack_id' do
        expect(subject.slack_id).to eq slack_id
      end

      it 'should populate private metadata' do
        expect(subject.private_metadata).to eq private_metadata
      end
      
      it 'should populate the context response_url' do
        expect(subject.response_url).to eq response_url 
      end

      it 'should assign a trigger_id' do
        expect(subject.trigger_id).to eq trigger_id
      end
    end
  end 
end 
