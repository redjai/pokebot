require 'storage/kanbanize/dynamodb/tasks/stay'

describe Storage::DynamoDB::Kanbanize::Tasks::ColumnStay do

 let(:entry_api_history_detail){ build(:api_history_detail,
                                details: "From 'foo.colZ' to 'test.colA'", 
                              entrydate: (Time.now - (3600 * 24)).strftime("%Y-%m-%d %H:%M:%S"),
                                taskid: exit_movement.history_detail.task_id)
                             }
 let(:entry_history_detail){ build(:history_detail, kanbanize_data: entry_api_history_detail) } 
 let(:entry_movement){ build(:movement, history_detail: entry_history_detail) } 
 let(:exit_movement){ build(:movement) }

  context 'entry =' do

    before do
      subject.entry = entry_movement
    end

    it 'should set the entry name' do
      expect(subject.name).to eq entry_movement.to_name
    end

    it 'should set the entry at datetime' do
      expect(subject.entry_at).to eq entry_movement.history_detail.entry_date
    end

    it 'should set the team_id' do
      expect(subject.team_id).to eq entry_movement.team_id
    end

    it 'should set the board_id' do
      expect(subject.board_id).to eq entry_movement.board_id
    end

    it 'should set the task_id' do
      expect(subject.task_id).to eq entry_movement.history_detail.task_id
    end
  end

  context 'exit =' do

    before do
      subject.exit = exit_movement
    end

    it 'should set the entry name' do
      expect(subject.name).to eq exit_movement.from_name
    end

    it 'should set the entry at datetime' do
      expect(subject.exit_at).to eq exit_movement.history_detail.entry_date
    end

    it 'should set the team_id' do
      expect(subject.team_id).to eq exit_movement.team_id
    end

    it 'should set the board_id' do
      expect(subject.board_id).to eq exit_movement.board_id
    end

    it 'should set the task_id' do
      expect(subject.task_id).to eq exit_movement.history_detail.task_id
    end

  end

  context 'duration' do

    before do
      subject.exit = exit_movement
      subject.entry = entry_movement
    end

    let(:duration){ (DateTime.parse(exit_movement.history_detail.entry_date) - DateTime.parse(entry_movement.history_detail.entry_date)) * 24.0 }

    it 'should return the difference between exit and entry in hours' do
      expect(subject.duration).to eq duration
    end

  end

  context 'paranoia' do

    before do
      subject.entry = entry_movement
    end

    context 'bad name' do

      it 'should not allow a different name to be assigned' do
        allow(exit_movement).to receive(:from_name).and_return('BAD.NAME')
        subject.exit = exit_movement
        expect(subject.errors).to include("expected new value  for 'name=BAD.NAME' to match existing 'name=test.cola'")
      end

    end

    context 'bad team id' do

      it 'should not allow a different team_id to be assigned' do
        exit_movement.team_id = 'TBAD'
        subject.exit = exit_movement
        expect(subject.errors).to include("expected new value  for 'team_id=TBAD' to match existing 'team_id=T12345'")
      end

    end

    context 'bad board id' do

      it 'should not allow a different team_id to be assigned' do
        exit_movement.board_id = '666'
        subject.exit = exit_movement
        expect(subject.errors).to include("expected new value  for 'board_id=666' to match existing 'board_id=4'")
      end

    end

    context 'bad task id' do

      it 'should not allow a different task-id to be assigned' do
        allow(exit_movement.history_detail).to receive(:task_id).and_return('other-task-id')
        subject.exit = exit_movement
        expect(subject.errors).to include("expected new value  for 'task_id=other-task-id' to match existing 'task_id=#{entry_movement.history_detail.task_id}'")
      end

    end
  end

  context 'bad times' do

    let(:dbl){ double("Movement", to_name: 'test.cola', from_name: 'test.colb') }
    let(:movement){ build(:movement) }

    context 'entry' do

      before do
        subject.exit = movement
      end

      let(:dbl){ double("Movement", to_name: 'test.cola') }
      let(:late){ (DateTime.parse(movement.history_detail.entry_date) + 1).iso8601 }
      let(:movement){ build(:movement) }

      it 'should raise an error if the entry is later than the exit' do
        allow(entry_movement.history_detail).to receive(:entry_date).and_return(late)
        subject.entry = entry_movement
        expect(subject.errors).to include("entry cannot be later than exit")
      end

    end

    context 'item' do

      before do
        subject.exit = exit_movement
        subject.entry = entry_movement
      end
   
      it 'should not fail' do
         puts subject.item
      end

    end

    context 'exit' do

      before do
        subject.entry = movement
      end

      let(:early){ (DateTime.parse(movement.history_detail.entry_date) - 1).iso8601 }

      it 'should raise an error if the entry is later than the exit' do
        allow(exit_movement.history_detail).to receive(:entry_date).and_return(early)
        subject.exit = exit_movement
        expect(subject.errors).to include("exit cannot be earlier than entry")
      end

    end
  end
end
