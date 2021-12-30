require 'storage/kanbanize/dynamodb/tasks/task_data'

describe Storage::Models::Kanbanize::TaskData do


  let(:team_id){ "T12345" }
  let(:fixture_file){ File.join("spec",'task_data','690.json') }
  let(:kanbanize_data){ JSON.parse(File.open(fixture_file).read) }

  subject{ described_class.new(team_id: team_id, kanbanize_data: kanbanize_data) }

  it 'should return an array of Movement' do
    subject.movements.each do |movement|
      expect(movement).to be_a Storage::Models::Movement
    end
  end

  it 'should return an arry ordered by history detail id' do
    subject.movements.collect{ |movement| movement.history_detail }
  end

  it 'should' do
    ClimateControl.modify BOARD_ROOT: "spec/structure_files" do
      subject.column_stays.each_value do |column_stay|
        puts column_stay.item if column_stay.valid?
      end
    end
  end
end