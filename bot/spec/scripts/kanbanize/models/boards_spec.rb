require 'scripts/kanbanize/models/boards'

describe Boards do

  subject{ described_class.new('spec/structure_files/*.json') }

  let(:structure_file_id){ "4" }

  before do
    subject.build!
  end

  context 'build' do

    it 'should' do
      expect(subject.boards[structure_file_id]).to be_a Board
    end

  end

  context 'built board' do

    let(:board){ subject.boards[structure_file_id] }
    let(:edge_names){
      [
        "New",
        "Options",
        "Next",
        "Refining",
        "Ready to implement",
        "Doing",
        "READY FOR PAIR TESTING",
        "PAIR TESTING",
        "Ready for peer review",
        "Reviewing",
        "Ready to verify",
        "QA Review",
        "Merged",
        "Staging",
        "PRODUCTION",
        "Done",
        "Temp Archive"
  ].collect{ |name| name.upcase }
    }

    it 'should' do
      board.edges.each_with_index do |edge, index|
        expect(edge.lcname).to eq edge_names[index]
      end
    end

  end

end