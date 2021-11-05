require 'storage/kanbanize/postgres/column_durations'
require 'storage/kanbanize/s3/task'

describe Storage::Postgres::ColumnDurations do

  let(:transition_a){ build(:history_detail, taskid: 123) }
  let(:transition_b){ build(:history_detail, taskid: 124) }

  let(:team_id){ 'testclient' }
  let(:board_id){ "77" }

  let(:history_details){ [transition_a, transition_b] }
  let(:task_id){ 123 }

  let(:column_name){ "Test.ColA" }
  let(:full_column_name) { "#{team_id}:#{board_id}:#{task_id}:#{column_name}" }

  subject{ described_class.new(team_id: team_id, board_id: board_id, history_details: history_details) }

  it 'should return entry sql' do
    expect(subject.history_entry_sql(transition_a)).to be_a String
  end

  it 'should return exit sql' do
    expect(subject.history_exit_sql(transition_a)).to be_a String
  end

  it 'should name the column' do
    expect(subject.column_name(task_id, column_name)).to eq full_column_name
  end

  it 'shou;d' do
    puts Storage::Kanbanize::TaskFetcher.new(team_id: 1, board_id: 2)
  end
  
end