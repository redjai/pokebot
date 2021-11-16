require 'storage/kanbanize/dynamodb/tasks/board_structures'

describe Storage::DynamoDB::Kanbanize::Tasks::Column do

  let(:name){ api_board_column['lcname'].downcase }
  let(:api_board_column){ build(:api_board_column) }
  subject{ described_class.new(kanbanize_data: api_board_column) }


  context '#name' do

    it 'should equal the downcase of the column name' do
      expect(subject.name).to eq name
    end

    context 'when there is a parent column' do

      let(:parent_api_board_column){ build(:api_board_column) }
      let(:name){ "#{parent_api_board_column['lcname']}.#{api_board_column['lcname']}".downcase }
      subject{ described_class.new(kanbanize_data: api_board_column, parent_kanbanize_data: parent_api_board_column) }


      it 'should include the parent name' do
        expect(subject.name).to eq name
      end

    end

  end

end

describe Storage::DynamoDB::Kanbanize::Tasks::BoardStructure do

  let(:board_structure){ { 'columns' => [api_board_column, api_board_column_with_children] } }
  let(:api_board_column){ build(:api_board_column) }
  let(:api_board_column_with_children){ build(:api_board_column, :with_children) }

  let(:column1){ api_board_column['lcname'].downcase }
  let(:column2){ "#{api_board_column_with_children['lcname']}.#{api_board_column_with_children['children'][0]['lcname']}".downcase }
  let(:column3){ "#{api_board_column_with_children['lcname']}.#{api_board_column_with_children['children'][1]['lcname']}".downcase }
  let(:column4){ "#{api_board_column_with_children['lcname']}.#{api_board_column_with_children['children'][2]['lcname']}".downcase }

  subject{ described_class.new(board_structure) }


  context '#columns' do

    it 'should create a flat array of columns' do
      expect(subject.columns.first.name).to eq column1
      expect(subject.columns[1].name).to eq column2
      expect(subject.columns[2].name).to eq column3
      expect(subject.columns[3].name).to eq column4
    end
  end

  context '#section' do

    let(:section){ api_board_column_with_children['children'][1]['section'] }
    let(:bad_name){ "Slartibardfast" }

    it 'should return the section of the named column regardless of case' do
      expect(subject.section(column3.upcase)).to eq section
    end

    it 'should return nil if there is no column with the name' do
      expect(subject.section(bad_name)).to be nil
    end

  end
end

describe Storage::DynamoDB::Kanbanize::Tasks::BoardStructures do

  let(:team_id){ 'T12345' }
  let(:board_id){ '4' }
  let(:file){ File.join(team_id, "#{board_id}.json") }
  let(:default_board_root){ File.join("data","boards") }

  context '#board_file' do

    it 'should return a file name' do
      expect(subject.board_file(team_id, board_id)).to eq File.join(default_board_root, file)
    end

  end
  
  context '#board_root' do
    
    it 'should default without an ENV variable' do
      expect(subject.board_root).to eq default_board_root
    end

    it 'should be able to modify the board data root in an ENV variable' do
      ClimateControl.modify BOARD_ROOT: "ABC" do
        expect(subject.board_root).to eq "ABC"
      end
    end
  end

  context 'board' do

    let(:columns){ 17 } #number of columns in the sample json file excluding parent columns

    it 'should load the requested team board' do
      ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
        expect(subject.board(team_id, board_id).columns.length).to eq columns
      end
    end

    it 'should return a BoardStructure object' do
      ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
        expect(subject.board(team_id, board_id)).to be_a Storage::DynamoDB::Kanbanize::Tasks::BoardStructure
      end
    end

  end

end
