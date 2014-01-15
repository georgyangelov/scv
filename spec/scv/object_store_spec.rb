require 'spec_helper'
require 'fakefs/safe'
require 'json'

describe SCV::ObjectStore do

  subject { described_class.new '.scv' }

  before(:each) do
    FakeFS.activate!

    FileUtils.mkdir_p '.scv'
  end

  after(:each) do
    FileUtils.rm_r '.scv'

    FakeFS.deactivate!
  end

  it 'can store and retrieve a blob' do
    blob = SCV::Objects::Blob.new content: 'file content'

    subject.store blob.id, blob

    expect(subject.fetch(blob.id)).to eq blob
  end

  it 'can store and retrieve a tree' do
    tree = SCV::Objects::Tree.new files: {'file1' => 'content1'},
                                  trees: {'dir1'  => '123456'  }

    subject.store tree.id, tree

    expect(subject.fetch(tree.id)).to eq tree
  end

  it 'can store and retrieve a commit' do
    commit = SCV::Objects::Commit.new message: 'message',
                                      tree:    '1234567',
                                      parent:  '7654321',
                                      author:  'me',
                                      date:    DateTime.now

    subject.store commit.id, commit

    expect(subject.fetch(commit.id)).to eq commit
  end

  it 'can store and retrieve a label' do
    label = SCV::Objects::Label.new id:           'master',
                                    reference_id: '123456'

    subject.store label.id, label

    expect(subject.fetch(label.id)).to eq label
  end

  describe '#key?' do
    it 'returns true for existing objects' do
      tree = SCV::Objects::Tree.new files: {'file1' => 'content1'},
                                    trees: {'dir1'  => '123456'  }

      subject.store tree.id, tree

      expect(subject.key? tree.id).to be_true
    end

    it 'returns false for non-existing objects' do
      expect(subject.key? '123456').to be_false
    end

    it 'works correctly with named objects' do
      label = SCV::Objects::Label.new id:           'master',
                                      reference_id: '123456'

      subject.store label.id, label

      expect(subject.key? 'master').to be_true
      expect(subject.key? 'HEAD'  ).to be_false
    end
  end

  describe '#each' do
    it 'works with empty set of named objects' do
      expect(subject.each.to_a).to match_array []
    end

    it 'enumerates all named object names' do
      label1 = SCV::Objects::Label.new id:           'HEAD',
                                       reference_id: '123456'
      label2 = SCV::Objects::Label.new id:           'master',
                                       reference_id: '123456'

      subject.store label1.id, label1
      subject.store label2.id, label2

      expect(subject.each.to_a).to match_array %w(HEAD master)
    end
  end

end