require 'storage/kanbanize/dynamodb/tasks/movement'

describe Storage::Models::Movement do

  let(:team_id){ 'T12345' }
  let(:board_id){ '4' }
  let(:valid_api_history_detail){ build(:api_history_detail, :column_movement) }
  let(:valid_history_detail){ Storage::Models::Kanbanize::HistoryDetail.new(team_id: team_id, kanbanize_data:  valid_api_history_detail) }

  context '::build' do
  
    let(:invalid_history_detail){ Storage::Models::Kanbanize::HistoryDetail.new(team_id: team_id, kanbanize_data:  invalid_api_history_detail) }
    let(:invalid_api_history_detail){ build(:api_history_detail, details: 'not a column movement') }

    it 'should return a movement if there is a valid from-to detail' do
      expect(described_class.build(team_id: team_id, board_id: board_id, history_detail: valid_history_detail)).to be_a described_class
    end

    it 'should return nil if there is not a valid from-to detail' do
      expect(described_class.build(team_id: team_id, board_id: board_id, history_detail: invalid_history_detail)).to be nil
    end
  end

  context '#cols' do

    subject{ described_class.build(team_id: team_id, board_id: board_id, history_detail: valid_history_detail) }

    it 'should return the from name extracted from the history details' do
      expect(subject.from_name).to eq 'test.cola'
    end 

    it 'should return the to name extracted from the history details' do
      expect(subject.to_name).to eq 'test.colb'
    end 
  end

  context 'section_boundary' do

    let(:history_detail){ double('HistoryDetail', details: details) }
    subject{ described_class.build(team_id: team_id, board_id: board_id, history_detail: history_detail) }

    context 'movement does not cross boundary' do

      let(:details){ "From 'Discovery.refining' to 'Discovery.Ready to implement'" }

      it 'should be false' do
        expect(subject.section_boundary?).to be false
      end

    end

    context 'movement does cross boundary' do

      let(:details){ "From 'Discovery.refining' to 'Implementing.DOING'" }

      it 'should be true' do
        expect(subject.section_boundary?).to be true
      end

    end
  end

  context 'section' do

    let(:history_detail){ double('HistoryDetail', details: details) }
    let(:details){ "From 'Discovery.refining' to 'Implementing.DOING'" }
    subject{ described_class.build(team_id: team_id, board_id: board_id, history_detail: history_detail) }

    context 'names' do

      it 'should return the from section name based on the from column name' do
        ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
          expect(subject.from_section_name).to eq "requested"
        end
      end

      it 'should return the to section name based on the from column name' do
        ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
          expect(subject.to_section_name).to eq "progress"
        end
      end

    end

    context 'delta' do

      it 'should be valid if there are two section names' do
        ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
          expect(subject.delta).to eq ["discovery.refining", "discovery.ready to implement", "implementing.doing"]
        end
      end

    end

    context 'validity' do

      it 'should be valid if there are two section names' do
        ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
          expect(subject.section_valid?).to be true
        end
      end

      context 'from invalid' do

        let(:details){ "From 'XYZ' to 'Implementing.DOING'" }

        it 'should not be valid if the from name does not match a section' do
          ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
            expect(subject.section_valid?).to be false
          end
        end

      end  
      
      context 'to invalid' do

        let(:details){ "From 'Discovery.refining' to 'XYZ'" }

        it 'should be valid if the to name does not match a section' do
          ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
            expect(subject.section_valid?).to be false
          end
        end

      end  
    end
  end
end
