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
    blob = VCSToolkit::Objects::Blob.new content: 'file content'

    subject.store blob.object_id, blob

    expect(subject.fetch(blob.object_id)).to eq blob
  end

  it 'can store and retrieve a tree' do
    tree = VCSToolkit::Objects::Tree.new files: {'file1' => 'content1'},
                                         trees: {'dir1'  => '123456'  }

    subject.store tree.object_id, tree

    expect(subject.fetch(tree.object_id)).to eq tree
  end

  it 'can store and retrieve a commit' do
    commit = VCSToolkit::Objects::Commit.new message: 'message',
                                             tree:    '1234567',
                                             parent:  '7654321',
                                             author:  'me',
                                             date:    '2013-12-27 16:06:00'

    subject.store commit.object_id, commit

    expect(subject.fetch(commit.object_id)).to eq commit
  end

  it 'can store and retrieve a label' do
    label = VCSToolkit::Objects::Label.new object_id:    'master',
                                           reference_id: '123456'

    subject.store label.object_id, label

    expect(subject.fetch(label.object_id)).to eq label
  end

  describe '#key?' do
    it 'returns true for existing objects' do
      tree = VCSToolkit::Objects::Tree.new files: {'file1' => 'content1'},
                                           trees: {'dir1'  => '123456'  }

      subject.store tree.object_id, tree

      expect(subject.key? tree.object_id).to be_true
    end

    it 'returns false for non-existing objects' do
      expect(subject.key? '123456').to be_false
    end

    it 'works correctly with named objects' do
      label = VCSToolkit::Objects::Label.new object_id:    'master',
                                             reference_id: '123456'

      subject.store label.object_id, label

      expect(subject.key? 'master').to be_true
      expect(subject.key? 'HEAD'  ).to be_false
    end
  end

  describe '#each' do
    it 'works with empty set of named objects' do
      expect(subject.each.to_a).to match_array []
    end

    it 'enumerates all named object names' do
      label1 = VCSToolkit::Objects::Label.new object_id:    'HEAD',
                                              reference_id: '123456'
      label2 = VCSToolkit::Objects::Label.new object_id:    'master',
                                              reference_id: '123456'

      subject.store label1.object_id, label1
      subject.store label2.object_id, label2

      expect(subject.each.to_a).to match_array %w(HEAD master)
    end
  end

end