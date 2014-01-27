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

    it 'creates a head label' do
      repo = SCV::Repository.create_at 'repo/'

      expect(repo[:head].reference_id).to be nil
    end

    it 'stores the current SCV version' do
      repo = SCV::Repository.create_at 'repo/'

      expect(File.read('repo/.scv/config/version')).to eq SCV::VERSION
    end
  end

  describe '.migrate' do
    let(:migrations) do
      {
        '0.0.1' => double(SCV::Migration, version: [0, 0, 1]),
        '1.4.1' => double(SCV::Migration, version: [1, 4, 1]),
        '2.0.1' => double(SCV::Migration, version: [2, 0, 1]),
        '2.1.3' => double(SCV::Migration, version: [2, 1, 3]),
      }
    end

    let(:working_dir)  { SCV::FileStore.new 'repo' }
    let(:object_store) { SCV::ObjectStore.new SCV::FileStore.new('repo/.scv') }

    it 'does nothing if the version is the latest' do
      migrations_done = SCV::Repository.enum_for(:migrate,
                                                 working_dir,
                                                 object_store,
                                                 migrations: migrations.values,
                                                 repository_version: '1.1.1',
                                                 last_version: '1.1.1').to_a

      expect(migrations_done).to be_empty
    end

    it 'applies only the migrations for newer versions' do
      expect(migrations['0.0.1']).to receive(:should_apply_to?).with('1.4.1').and_return(false)
      expect(migrations['1.4.1']).to receive(:should_apply_to?).with('1.4.1').and_return(false)
      expect(migrations['2.0.1']).to receive(:should_apply_to?).with('1.4.1').and_return(true)
      expect(migrations['2.1.3']).to receive(:should_apply_to?).with('1.4.1').and_return(true)

      expect(migrations['2.0.1']).to receive(:apply).with(working_dir, object_store).ordered
      expect(migrations['2.1.3']).to receive(:apply).with(working_dir, object_store).ordered

      migrations_done = SCV::Repository.enum_for(:migrate,
                                                 working_dir,
                                                 object_store,
                                                 migrations: migrations.values,
                                                 repository_version: '1.4.1',
                                                 last_version: '2.1.3').to_a

      expect(migrations_done.map(&:version)).to match_array [
        [2, 0, 1],
        [2, 1, 3],
      ]
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
    repository.stub(:object_store) do
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
        expect { repository.resolve(:commit, :label)  }.to raise_error
        expect { repository.resolve(:unknown, :label) }.to raise_error
      end
    end
  end

end