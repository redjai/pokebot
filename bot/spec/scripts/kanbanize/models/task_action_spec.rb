require 'scripts/kanbanize/models/task_action'

describe TaskAction do

  subject{ build(:task_action) }

  context 'created?' do

    subject{ build(:task_action, entry_history_event: 'Task created') }

    it 'should' do
      expect(subject.created?).to be true
    end
  end

  context 'archived?' do

    subject{ build(:task_action, exit_history_event: 'Task archived') }

    it 'should' do
      expect(subject.archived?).to be true
    end
  end

  context 'duration' do

    subject{ build(:task_action, exit_at: exit_at, entry_at: entry_at) }

    context 'entry_at and exit_at are both times' do

      let(:exit_at){ Time.now - 3600 }
      let(:entry_at){ Time.now - 7200 }

      it 'should return the duration in whole hours' do
        expect(subject.duration).to eq 1
      end
    end

    context 'entry_at is nil' do

      let(:exit_at){ Time.now - 3600 }
      let(:entry_at){ nil }

      it 'should return the duration in whole hours' do
        expect(subject.duration).to be nil
      end
    end

    context 'exit_at is nil' do

      let(:exit_at){ nil }
      let(:entry_at){ Time.now - 3600 }

      it 'should return the duration in whole hours' do
        expect(subject.duration).to be nil
      end
    end
  end

  context 'exit_at_date' do

    subject{ build(:task_action, exit_at: exit_at) }

    context 'exit_at is a Time' do

      let(:exit_at){ Time.now - 3600 * 10 }

      it 'should return a date' do
        expect(subject.exit_at_date).to eq exit_at.to_date
      end

    end

    context 'exit_at is null' do

      let(:exit_at){ nil }
    
      it 'should return a date' do
        expect(subject.exit_at_date).to be_nil
      end

    end

  end

  context 'entry_at_date' do

    subject{ build(:task_action, entry_at: entry_at) }

    context 'entry_at is a Time' do

      let(:entry_at){ Time.now - 3600 * 10 }

      it 'should return a date' do
        expect(subject.entry_at_date).to eq entry_at.to_date
      end
    end

    context 'entry_at is null' do
      let(:entry_at){ nil }
    
      it 'should return a date' do
        expect(subject.entry_at_date).to be_nil
      end
    end

  end

  context 'date_range' do

    subject{ build(:task_action, exit_at: exit_at, entry_at: entry_at) }

    context 'entry_at and exit_at are both times' do

      let(:exit_at){ Time.now - 3600 }
      let(:entry_at){ Time.now - 3600 * 120 }
      let(:date_range){ (entry_at.to_date..exit_at.to_date) }

      it 'should return the duration in whole hours' do
        expect(subject.date_range).to eq date_range
      end
    end

    context 'entry_at is nil' do

      let(:exit_at){ Time.now - 3600 }
      let(:entry_at){ nil }

      it 'should return the duration in whole hours' do
        expect(subject.date_range).to be nil
      end
    end

    context 'exit_at is nil' do

      let(:exit_at){ nil }
      let(:entry_at){ Time.now - 3600 }

      it 'should return the duration in whole hours' do
        expect(subject.date_range).to be nil
      end
    end

  end

  context 'wait_length_on' do
    context 'entered that day' do

      subject{ build(:task_action, entry_at: entry_at) }

      let(:entry_at){ DateTime.new(2021,1,1,10) } 

      it 'should start the day from the time of entry' do
        expect(subject.wait_length_on(entry_at)).to eq(24 - entry_at.hour)
      end

    end

    context 'exited that day' do

      subject{ build(:task_action, exit_at: exit_at) }

      let(:exit_at){ DateTime.new(2021,1,3,10)  }

      it 'should start the day from the time of entry' do
        expect(subject.wait_length_on(exit_at)).to eq 10
      end

    end

    context 'waited that day' do

      subject{ build(:task_action, exit_at: exit_at, entry_at: entry_at) }

      let(:entry_at){ DateTime.new(2021,1,1,10) } 
      let(:exit_at){ DateTime.new(2021,1,3,10)  }
      let(:waited){ Date.civil(2021,1,2) }

      it 'should start the day from the time of entry' do
        expect(subject.wait_length_on(waited)).to eq 24
      end

    end

  end

  context 'actions on' do

    context 'entries on' do

      subject{ build(:task_action, entry_at: entry_at, entry_history_event: entry_history_event) }

      let(:entry_at){ DateTime.new(2021,1,1,10) } 
      let(:exit_at){ DateTime.new(2021,1,3,10)  }
      let(:waited){ Date.civil(2021,1,2) }

      context 'entry' do

        let(:entry_history_event) { 'Task moved' }

        it 'should' do
          expect(subject.entered_on(entry_at.to_date)).to eq described_class::Actions::ENTERED
        end

        it 'should' do
          expect(subject.entered_on(entry_at.to_date + 1)).to be nil
        end

        it 'should' do
          expect(subject.entered_on(entry_at.to_date - 1)).to be nil
        end

      end

      context 'created' do

        let(:entry_history_event) { 'Task created' }

        it 'should' do
          expect(subject.entered_on(entry_at.to_date)).to eq described_class::Actions::CREATED
        end

        it 'should' do
          expect(subject.entered_on(entry_at.to_date + 1)).to be nil
        end

        it 'should' do
          expect(subject.entered_on(entry_at.to_date - 1)).to be nil
        end

      end

    end

    context 'waits on' do

      subject{ build(:task_action, entry_at: entry_at, exit_at: exit_at, entry_history_event: entry_history_event, exit_history_event: exit_history_event) }

      let(:entry_at){ DateTime.new(2021,1,1,10) }
      let(:exit_at){ DateTime.new(2021,1,3,10)  }
      let(:waited){ Date.civil(2021,1,2) }
      let(:entry_history_event) { 'Task moved' }
      let(:exit_history_event) { 'Task moved' }

      context 'waits on day entered' do

        context 'entered before 12' do
          let(:entry_at){ DateTime.new(2021,1,1,10) }

          it 'should' do
            expect(subject.waited_on(entry_at.to_date)).to eq described_class::Actions::WAITED
          end
        end

        context 'entered after 12' do
          let(:entry_at){ DateTime.new(2021,1,1,13) }

          it 'should' do
            expect(subject.waited_on(entry_at.to_date)).to be nil
          end
        end
      end

      context 'waits on day exited' do

        context 'exited before 12' do
          let(:exit_at){ DateTime.new(2021,1,3,10) }

          it 'should' do
            expect(subject.waited_on(exit_at.to_date)).to eq nil
          end
        end

        context 'exited after 12' do
          let(:exit_at){ DateTime.new(2021,1,3,13) }

          it 'should' do
            expect(subject.waited_on(exit_at.to_date)).to be described_class::Actions::WAITED
          end
        end
      end

      context 'enters and exits on same day' do

        context 'more than 12 hours apart' do
          let(:entry_at){ DateTime.new(2021,1,1,8) }
          let(:exit_at){ DateTime.new(2021,1,1,21)  }

          it 'should' do
            expect(subject.waited_on(entry_at.to_date)).to eq described_class::Actions::WAITED
          end
        end

        context 'entered after 12' do
          let(:entry_at){ DateTime.new(2021,1,1,8) }
          let(:exit_at){ DateTime.new(2021,1,1,9)  }

          it 'should' do
            expect(subject.waited_on(entry_at.to_date)).to be nil
          end
        end
      end

      context 'waits on days not exited or entered' do    
        let(:exit_at){ DateTime.new(2021,1,3,13) }

        it 'should' do
          expect(subject.waited_on(waited)).to be described_class::Actions::WAITED
        end
      end

      context 'exits' do

        context 'exit' do

          it 'should' do
            expect(subject.exited_on(exit_at.to_date)).to eq described_class::Actions::EXITED
          end
  
          it 'should' do
            expect(subject.exited_on(exit_at.to_date + 1)).to be nil
          end
  
          it 'should' do
            expect(subject.exited_on(exit_at.to_date - 1)).to be nil
          end
  
        end
  
        context 'archived' do

          let(:exit_history_event) { 'Task archived' }
  
          it 'should' do
            expect(subject.exited_on(exit_at.to_date)).to eq described_class::Actions::ARCHIVED
          end
  
          it 'should' do
            expect(subject.exited_on(exit_at.to_date + 1)).to be nil
          end
  
          it 'should' do
            expect(subject.exited_on(exit_at.to_date - 1)).to be nil
          end
        end
      end
    end
  end
end