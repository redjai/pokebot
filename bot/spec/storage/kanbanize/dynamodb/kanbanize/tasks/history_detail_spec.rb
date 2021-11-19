require 'storage/kanbanize/dynamodb/tasks/history_detail'

describe Storage::DynamoDB::Kanbanize::Tasks::HistoryDetail do

  let(:api_history_detail){ build(:api_history_detail) }
  let(:team_id){ Faker::Team.name }
  let(:id){ "#{team_id}-#{api_history_detail['historyid']}" }

  let(:iso8601){  /(\d{4})-(\d{2})-(\d{2})T(\d{2})\:(\d{2})\:(\d{2})[+-](\d{2})\:(\d{2})/ }

  subject{ described_class.new(team_id: team_id, kanbanize_data: api_history_detail) }

  context '#id' do
  
    it 'id be team id and history id' do
      expect(subject.id).to eq id
    end

    it 'should merge the id into the item' do
      expect(subject.item['id']).to eq id
    end

   end

   context 'entrydate' do

     it 'should be an iso8601 date' do
       expect(subject.entry_date =~ iso8601).to be_truthy 
     end

     it 'should merge the id into the item' do
      expect(subject.item['entrydate'] =~ iso8601).to be_truthy 
    end

   end

end