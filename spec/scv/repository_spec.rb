require 'spec_helper'
require 'fakefs/safe'

describe SCV::Repository do

  before(:each) do
    FakeFS.activate!
  end

  after(:each) do
    FileUtils.rm_r '.'

    FakeFS.deactivate!
  end

  it 'can initialize the directory structure' do
    SCV::Repository.create_at 'sample/'

    expect(File.directory? 'sample/.scv').to be_true
    expect(Dir.entries     'sample/.scv').to match_array %w(. .. objects refs blobs config)
  end

end