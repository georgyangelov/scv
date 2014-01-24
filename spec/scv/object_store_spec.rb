require 'spec_helper'
require 'json'

describe SCV::ObjectStore do

  subject(:object_store) { described_class.new '.scv' }

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

    object_store.store blob.id, blob

    expect(object_store.fetch(blob.id)).to eq blob
  end

  it 'can store and retrieve a tree' do
    tree = SCV::Objects::Tree.new files: {'file1' => 'content1'},
                                  trees: {'dir1'  => '123456'  }

    object_store.store tree.id, tree

    expect(object_store.fetch(tree.id)).to eq tree
  end

  it 'can store and retrieve a commit' do
    commit = SCV::Objects::Commit.new message: 'message',
                                      tree:    '1234567',
                                      parent:  '7654321',
                                      author:  'me',
                                      date:    DateTime.now

    object_store.store commit.id, commit

    expect(object_store.fetch(commit.id)).to eq commit
  end

  it 'can store and retrieve a label' do
    label = SCV::Objects::Label.new id:           'master',
                                    reference_id: '123456'

    object_store.store label.id, label

    expect(object_store.fetch(label.id)).to eq label
  end

  describe '#key?' do
    it 'returns true for existing objects' do
      tree = SCV::Objects::Tree.new files: {'file1' => 'content1'},
                                    trees: {'dir1'  => '123456'  }

      object_store.store tree.id, tree

      expect(object_store.key? tree.id).to be_true
    end

    it 'returns true for existing blobs' do
      blob = SCV::Objects::Blob.new content: 'file content'

      object_store.store blob.id, blob

      expect(object_store.key? blob.id).to be_true
    end

    it 'returns false for non-existing objects' do
      expect(object_store.key? '123456').to be_false
    end

    it 'works correctly with named objects' do
      label = SCV::Objects::Label.new id:           'master',
                                      reference_id: '123456'

      object_store.store label.id, label

      expect(object_store.key? 'master').to be_true
      expect(object_store.key? 'HEAD'  ).to be_false
    end
  end

  describe '#each' do
    it 'works with empty set of named objects' do
      expect(object_store.each.to_a).to match_array []
    end

    it 'enumerates all named object names' do
      label1 = SCV::Objects::Label.new id:           'HEAD',
                                       reference_id: '123456'
      label2 = SCV::Objects::Label.new id:           'master',
                                       reference_id: '123456'

      object_store.store label1.id, label1
      object_store.store label2.id, label2

      expect(object_store.each.to_a).to match_array %w(HEAD master)
    end
  end

end