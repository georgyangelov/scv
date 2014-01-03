require 'spec_helper'
require 'fakefs/safe'

describe SCV::Repository do

  subject(:repository) { SCV::Repository.create_at 'repo/' }

  before(:each) do
    FakeFS.activate!
  end

  after(:each) do
    FileUtils.rm_r '.'

    FakeFS.deactivate!
  end

  describe '.create_at' do
    it 'initializes the directory structure' do
      repository

      expect(File.directory? 'repo/.scv').to be_true
      expect(Dir.entries     'repo/.scv').to match_array %w(. .. objects refs blobs config)
    end

    it 'creates a head label' do
      expect(repository[:head].reference_id).to be nil
    end
  end

  it 'finds and creates labels' do
    repository.send :create_label, 'test_label', '123456'
    expect(repository[:test_label]).to be_a SCV::Objects::Label
  end

end