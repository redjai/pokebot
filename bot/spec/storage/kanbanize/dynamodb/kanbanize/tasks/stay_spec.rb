require 'storage/kanbanize/dynamodb/tasks/stay'

describe Storage::DynamoDB::Kanbanize::Tasks::ColumnStay do

 let(:movement){ build(:movement) }

  context 'entry =' do

    before do
      subject.entry = movement
    end

    it 'should set the entry name' do
      expect(subject.name).to eq movement.to_name
    end

    it 'should set the entry at datetime' do
      expect(subject.entry_at).to eq movement.history_detail.entrydate
    end

    it 'should set the team_id' do
      expect(subject.team_id).to eq movement.team_id
    end

    it 'should set the board_id' do
      expect(subject.board_id).to eq movement.board_id
    end

    it 'should set the task_id' do
      expect(subject.task_id).to eq movement.history_detail.task_id
    end
  end

  context 'exit =' do

    before do
      subject.exit = movement
    end

    it 'should set the entry name' do
      expect(subject.name).to eq movement.from_name
    end

    it 'should set the entry at datetime' do
      expect(subject.exit_at).to eq movement.history_detail.entrydate
    end

    it 'should set the team_id' do
      expect(subject.team_id).to eq movement.team_id
    end

    it 'should set the board_id' do
      expect(subject.board_id).to eq movement.board_id
    end

    it 'should set the task_id' do
      expect(subject.task_id).to eq movement.history_detail.task_id
    end

  end

  context 'paranoia' do

    before do
      subject.entry = movement
    end

    context 'bad name' do

      it 'should not allow a different name to be assigned' do
        expect{
          subject.exit = movement #this will try to change the name of the stay
        }.to raise_error(ArgumentError,"expected new value test.cola for name to equal existing value but found test.colb")
      end

    end

    context 'bad team id' do

      it 'should not allow a different team_id to be assigned' do
        allow(movement).to receive(:from_name).and_return(subject.name)
        movement.team_id = 'TBAD'
        expect{
          subject.exit = movement #this will try to change the name of the stay
        }.to raise_error(ArgumentError,"expected new value TBAD for team_id to equal existing value but found T12345")
      end

    end

    context 'bad board id' do

      it 'should not allow a different team_id to be assigned' do
        allow(movement).to receive(:from_name).and_return(subject.name)
        movement.board_id = '666'
        expect{
          subject.exit = movement #this will try to change the name of the stay
        }.to raise_error(ArgumentError,"expected new value 666 for board_id to equal existing value but found 4")
      end

    end

    context 'bad task id' do

      it 'should not allow a different task-id to be assigned' do
        allow(movement).to receive(:from_name).and_return(subject.name)
        allow(movement.history_detail).to receive(:task_id).and_return('other-task-id')
        expect{
          subject.exit = movement #this will try to change the name of the stay
        }.to raise_error(ArgumentError,"expected new value other-task-id for task_id to equal existing value but found 22")
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
      let(:late){ (DateTime.parse(movement.history_detail.entrydate) + 1).iso8601 }
      let(:movement){ build(:movement) }

      it 'should raise an error if the entry is later than the exit' do
        allow(dbl).to receive_message_chain("history_detail.entrydate").and_return(late)
        expect{
          subject.entry = dbl
        }.to raise_error(ArgumentError,"entry cannot be later than exit")
      end

    end

    context 'exit' do

      before do
        subject.entry = movement
      end

      let(:early){ (DateTime.parse(movement.history_detail.entrydate) - 1).iso8601 }

      it 'should raise an error if the entry is later than the exit' do
        allow(dbl).to receive_message_chain("history_detail.entrydate").and_return(early)
        expect{
          subject.exit = dbl
        }.to raise_error(ArgumentError,"exit cannot be earlier than entry")
      end

    end
  end
end
