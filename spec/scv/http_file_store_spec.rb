require 'spec_helper'

describe SCV::HTTPFileStore do

  let(:files) do
    {
      'README.md'                             => 'This is a readme file',
      'lib/vcs_toolkit.rb'                    => 'require ...',
      'lib/vcs_toolkit/utils/memory_store.rb' => 'class MemoryStore',
      'lib/vcs_toolkit/utils/object_store.rb' => 'class ObjectStore',
      'lib/vcs_toolkit/objects/object.rb'     => 'class Object',
    }
  end

  let(:base_path) { 'repo/' }
  subject(:store) { described_class.new "http://localgost/#{base_path}" } # Not a typo

  before(:each) do
    stub_request(:get, /localgost\/repo\/.*/).to_return do |request|
      path = request.uri.path.sub(base_path, '').sub(/^\//, '')

      if files.key? path
        {body: files[path]}
      else
        {status: 404}
      end
    end

    stub_request(:head, /localgost\/repo\/.*/).to_return do |request|
      path = request.uri.path.sub(base_path, '').sub(/^\//, '')

      if files.key? path
        {status: 200}
      else
        {status: 404}
      end
    end

    stub_request(:put, /localgost\/repo\/.*/).to_return do |request|
      path = request.uri.path.sub(base_path, '').sub(/^\//, '')

      files[path] = request.body

      {status: 200}
    end
  end

  it 'can fetch a file in root' do
    expect(store.fetch('README.md')).to eq files['README.md']
  end

  it 'can fetch a file in another dir' do
    expect(store.fetch('lib/vcs_toolkit.rb')).to eq files['lib/vcs_toolkit.rb']
    expect(store.fetch('lib/vcs_toolkit/utils/memory_store.rb')).to eq 'class MemoryStore'
  end

  it 'raises KeyError on non-existent files' do
    expect { store.fetch('lib/file_that_never_was') }.to raise_error(KeyError)
  end

  it 'can store a file' do
    store.store 'bin/svc', 'simple version control'
    expect(store.fetch('bin/svc')).to eq 'simple version control'
  end

  describe '#file?' do
    it 'returns trueish value for a file' do
      expect(store.file?('README.md')).to be_true
      expect(store.file?('lib/vcs_toolkit.rb')).to be_true
      expect(store.file?('lib/vcs_toolkit/utils/memory_store.rb')).to be_true
    end

    it 'returns falsey value for a directory' do
      expect(store.file?('lib/')).to be_false
    end

    it 'returns falsey value for non-existent files' do
      expect(store.file?('data/test')).to be_false
      expect(store.file?('lib/vcs_toolkit/')).to be_false
    end
  end
end