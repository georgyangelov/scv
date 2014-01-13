require 'spec_helper'
require 'fakefs/safe'

describe SCV::Objects::Blob do

  let(:content)      { 'blob content' }
  let(:content_hash) { '59873e99cef61a60b3826e1cbb9d4b089ae78c2b' }

  context 'without explicit object_id' do
    subject(:blob) { described_class.new content: content }

    it 'has a generated object_id' do
      should respond_to :object_id
    end

    it 'has a default object_id of the blob content hash' do
      expect(blob.object_id).to eq content_hash
    end

    it 'has correct content_in_memory accessor' do
      expect(blob.content_in_memory).to be_true
    end
  end

  context 'with valid explicit object_id' do
    subject(:blob) { described_class.new content: content, object_id: content_hash }

    it 'doesn\'t raise an error' do
      expect { blob }.to_not raise_error
    end
  end

  context 'with invalid explicit object_id' do
    subject(:blob) { described_class.new content: content, object_id: '1234' }

    it 'raises an InvalidObjectError' do
      expect { blob }.to raise_error(VCSToolkit::InvalidObjectError)
    end
  end

  context 'with file path instead of content' do
    before(:each) do
      FakeFS.activate!

      File.write('README.md', content)
    end

    after(:each) do
      FileUtils.rm_r '.'

      FakeFS.deactivate!
    end

    subject(:blob) do
      described_class.new content: File.open('README.md', 'rb')
    end

    it 'generates correct object_id' do
      expect(blob.object_id).to eq content_hash
    end

    it 'keeps the file stream instead of its content' do
      expect(blob.content).to      be_a File
      expect(blob.content.read).to eq   content
    end

    it 'has correct content_in_memory accessor' do
      expect(blob.content_in_memory).to be_false
    end
  end

end