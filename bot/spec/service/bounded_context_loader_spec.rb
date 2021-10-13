require 'service/bounded_context_loader'

describe Service::BoundedContextLoader do

  
  let(:root){ "spec/support/bounded_contexts" }

  context 'arn' do

    let(:event_source_arn){ "arn:aws:sqs:eu-west-1:154682513313:gerty-development-sns-messages-to-sqs-test-bounded-context" }
    subject{ described_class.new(event_source_arn: event_source_arn, root: root) }

    context 'folders and files' do

      let(:arn_name){ 'test_bounded_context' }
      let(:bounded_context_folder){ File.join(root, arn_name) }
      
      it 'should return the context name from the arn' do
        expect(subject.name).to eq arn_name    
      end

      it 'should return the folder containig  the bouded contexts' do
        expect(subject.bounded_context_folder).to eq bounded_context_folder    
      end

    end
  end

  context 'files' do

    let(:event_source_arn){ "arn:aws:sqs:eu-west-1:154682513313:gerty-development-sns-messages-to-sqs-test-bounded-context" }
    subject{ described_class.new(event_source_arn: event_source_arn, root: root) }

    let(:arn_name){ 'test_bounded_context' }
    let(:bounded_context_folder){ File.join(root, arn_name) }
    let(:bounded_context_file_1){ File.join(root, arn_name, 'test_service_1.rb') }
    let(:bounded_context_file_2){ File.join(root, arn_name, 'test_service_2.rb') }
    let(:bounded_context_files){ [bounded_context_file_1, bounded_context_file_2]}

    it 'should return the files in the bounded context folder' do
      expect(subject.bounded_context_files).to eq bounded_context_files
    end

  end

  context 'name' do
    let(:direct_name){ 'named_context' }
    subject{ described_class.new(name: direct_name, root: root) }

    context 'folders and files' do

      let(:name){ 'test_bounded_context' }
      let(:bounded_context_folder){ File.join(root, direct_name) }
      
      it 'should return the context name from the name directly supplied' do
        expect(subject.name).to eq direct_name    
      end

      it 'should return the folder containig  the bouded contexts' do
        expect(subject.bounded_context_folder).to eq bounded_context_folder    
      end

    end
  end
end
