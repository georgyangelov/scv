require 'spec_helper'

describe SCV::Repository do

  before(:each) do
    FakeFS.activate!
  end

  after(:each) do
    FileUtils.rm_r '.'

    FakeFS.deactivate!
  end

  describe '.create_at' do
    it 'initializes the directory structure' do
      SCV::Repository.create_at 'repo/'

      expect(File.directory? 'repo/.scv').to be_true
      expect(Dir.entries     'repo/.scv').to match_array %w(. .. objects refs blobs config)
    end

    it 'creates head and master labels' do
      repo = SCV::Repository.create_at 'repo/'

      expect(repo[:head  ].reference_id).to eq "master"
      expect(repo[:master].reference_id).to be_nil
    end
  end

  subject(:repository) { SCV::Repository.create_at 'repo/' }

  let(:commit) do
    double(VCSToolkit::Objects::Commit, id:          'commit',
                                        tree:        'tree',
                                        object_type: :commit,
                                        parents:     [])
  end

  let(:commit_2) do
    double(VCSToolkit::Objects::Commit, id:          'commit_2',
                                        tree:        'tree',
                                        object_type: :commit,
                                        parents:     ['commit'])
  end

  let(:commit_3) do
    double(VCSToolkit::Objects::Commit, id:          'commit_3',
                                        tree:        'tree',
                                        object_type: :commit,
                                        parents:     ['commit', 'commit_2'])
  end

  let(:tree) do
    double(VCSToolkit::Objects::Tree,   id:          'tree',
                                        object_type: :tree)
  end

  let(:label_head) do
    double(VCSToolkit::Objects::Label,  id:           'head',
                                        reference_id: 'master',
                                        object_type:  :label)
  end

  let(:label_master) do
    double(VCSToolkit::Objects::Label,  id:           'master',
                                        reference_id: 'commit',
                                        object_type:  :label)
  end

  before(:each) do
    repository.stub(:object_store) do
      {
        commit.id       => commit,
        commit_2.id     => commit_2,
        commit_3.id     => commit_3,
        tree.id         => tree,
        label_head.id   => label_head,
        label_master.id => label_master,
      }
    end
  end

  describe '#resolve' do
    context 'with the direct object type' do
      it 'fetches labels directly' do
        expect(repository.resolve('head', :label)).to eq label_head
      end

      it 'fetches commits directly' do
        expect(repository.resolve(commit.id, :commit)).to eq commit
      end

      it 'fetches trees directly' do
        expect(repository.resolve(tree.id, :tree)).to eq tree
      end
    end

    context 'with different object type' do
      it 'resolves references to commits' do
        expect(repository.resolve('head', :commit)).to eq commit
      end

      it 'resolves references to trees from commits' do
        expect(repository.resolve(commit.id, :tree)).to eq tree
      end

      it 'resolves references to trees from labels' do
        expect(repository.resolve('head', :tree)).to eq tree
      end

      it 'raises an error if the resolution fails' do
        expect { repository.resolve(:commit, :label)  }.to raise_error
        expect { repository.resolve(:unknown, :label) }.to raise_error
      end
    end

    context 'with commit parent offset' do
      it 'follows the parent reference' do
        expect(repository.resolve("#{commit_2.id}~1", :commit)).to eq commit
      end

      it 'follows the parent reference from labels' do
        label_master.stub(:reference_id) { commit_2.id }

        expect(repository.resolve("head~1", :commit)).to eq commit
      end

      it 'raises an error if a commit has more than one parent' do
        expect { repository.resolve("#{commit_3.id}~1", :commit) }.to raise_error
      end

      it 'raises an error if the commit chain is shorter than the offset' do
        expect { repository.resolve("#{commit_2.id}~3", :commit) }.to raise_error
      end
    end
  end

end