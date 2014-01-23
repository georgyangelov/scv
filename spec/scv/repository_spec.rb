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

  describe '.create_at' do
    it 'initializes the directory structure' do
      SCV::Repository.create_at 'repo/'

      expect(File.directory? 'repo/.scv').to be_true
      expect(Dir.entries     'repo/.scv').to match_array %w(. .. objects refs blobs config)
    end

    it 'creates a head label' do
      repo = SCV::Repository.create_at 'repo/'

      expect(repo[:head].reference_id).to be nil
    end
  end

  subject(:repository) { SCV::Repository.create_at 'repo/' }

  let(:commit) do
    double(VCSToolkit::Objects::Commit, id: '1234', tree: '2345', object_type: :commit)
  end

  let(:tree) do
    double(VCSToolkit::Objects::Tree, id: '2345', object_type: :tree)
  end

  let(:label_head) do
    double(VCSToolkit::Objects::Label, id: :head, reference_id: :master, object_type: :label)
  end

  let(:label_master) do
    double(VCSToolkit::Objects::Label, id: :master, reference_id: '1234', object_type: :label)
  end

  before(:each) do
    repository.stub(:repository) do
      {
        commit.id       => commit,
        tree.id         => tree,
        label_head.id   => label_head,
        label_master.id => label_master,
      }
    end
  end

  describe '#resolve' do
    context 'with the direct object type' do
      it 'fetches labels directly' do
        expect(repository.resolve(:head, :label)).to eq repository[:head]
      end

      it 'fetches commits directly' do
        expect(repository.resolve(commit.id, :commit)).to eq repository[commit.id]
      end

      it 'fetches trees directly' do
        expect(repository.resolve(tree.id, :tree)).to eq repository[tree.id]
      end
    end

    context 'with different object type' do
      it 'resolves references to commits' do
        expect(repository.resolve(:head, :commit)).to eq repository[commit.id]
      end

      it 'resolves references to trees from commits' do
        expect(repository.resolve(commit.id, :tree)).to eq repository[tree.id]
      end

      it 'resolves references to trees from labels' do
        expect(repository.resolve(:head, :tree)).to eq repository[tree.id]
      end

      it 'raises an error if the resolution fails' do
        expect { repository.resolve(:commit, :label) }.to raise_error
      end
    end
  end

end