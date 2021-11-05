require 'storage/kanbanize/dynamodb/team'

describe Storage::Kanbanize::DynamoDB::Team do

  let(:last_board_id){ 2 }
  let(:board_ids){ [3] }
  let(:sorted){ board_ids.sort }

  subject{ 
    described_class.new({ 
      "team_id" => "test-client-1",
      "board_ids" => board_ids,
      "last_board_id" => last_board_id
    }) 
  }

  it 'should sort board_ids' do
    expect(subject.board_ids).to eq sorted
  end

  context "last_board_id is last in sorted board_ids" do

    let(:last_board_id){ 3 }

    it 'should use the last sorted board id' do
      expect(subject.last_board_id).to eq sorted.last 
    end
    
    it 'should return the first sorted board id' do
      expect(subject.board_id).to eq sorted.first
    end

  end

  context "last_board_id is null" do

    let(:last_board_id){ nil }

    it 'should use the last sorted board id' do
      expect(subject.last_board_id).to eq sorted.last 
    end
    
    it 'should return the first sorted board id' do
      expect(subject.board_id).to eq sorted.first
    end

  end
end
