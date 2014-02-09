require 'spec_helper'
require 'yaml'

describe SCV::Config do

  let(:file_store) { double(VCSToolkit::FileStore)            }
  subject(:config) { SCV::Config.new file_store, 'config.yml' }

  let(:content) do
    {
      'test' => {
        'inside' => 'one',
        'list-test' => [
          'item 1',
          'item 2',
        ]
      }
    }
  end

  before(:each) do
    allow(file_store).to receive(:file?).with('config.yml').and_return(true)
    allow(file_store).to receive(:fetch).with('config.yml').and_return(content.to_yaml)
  end

  it 'loads the configuration file in initialize' do
    expect(file_store).to receive(:file?).with('config.yml').and_return(true)
    expect(file_store).to receive(:fetch).with('config.yml').and_return(content.to_yaml)

    expect(config.data).to eq content
  end

  describe '#load' do
    it 'loads the config file' do
      expect(file_store).to receive(:fetch).with('config.yml').and_return(content.to_yaml)
      config.load

      expect(config.data).to eq content
    end

    it 'creates the config file if it does not exitst' do
      expect(file_store).to receive(:file?).with('config.yml').and_return(false)

      expect(config.data).to eq({})
    end
  end

  describe '#save' do
    it 'saves the configuration file' do
      config.data = content
      expect(file_store).to receive(:store).with('config.yml', content.to_yaml)

      config.save
    end
  end

  describe '#[]' do
    it 'proxies data#[]' do
      expect(config.data).to receive(:[]).with('key').and_return('value')
      expect(config['key']).to eq 'value'
    end

    it 'splits the key by dots and resolves deep structures' do
      expect(config['test.list-test']).to match_array [
        'item 1',
        'item 2'
      ]
    end
  end

  describe '#[]=' do
    it 'proxies data#[]=' do
      expect(config.data).to receive(:[]=).with('key', 'value').and_return('value')
      expect(config['key'] = 'value').to eq 'value'
    end

    it 'splits the key by dots and resolves deep structures' do
      config['test.inside'] = 'changed item'

      expect(config['test']['inside']).to eq 'changed item'
    end

    it 'sets the keys along the path to hashes' do
      config['this.should.create.hashes'] = 'yay!'

      expect(config['this']['should']['create']['hashes']).to eq 'yay!'
    end
  end

  describe '#delete' do
    it 'deletes direct keys' do
      config.delete 'test'
      expect(config.data.key? 'test').to be_false
    end

    it 'deletes nested keys' do
      config.delete 'test.inside'
      expect(config.data.key? 'test'     ).to be_true
      expect(config['test'].key? 'inside').to be_false
    end
  end
end