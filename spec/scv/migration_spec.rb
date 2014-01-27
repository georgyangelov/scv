require 'spec_helper'

describe SCV::Migration do
  subject(:migration) { SCV::Migration.new '1.2.3' }

  it { should respond_to :apply  }
  it { should respond_to :revert }

  describe '#should_apply_to?' do
    it 'is false for a newer bugfix version' do
      expect(migration.should_apply_to? '1.2.11').to be_false
    end

    it 'is false for a newer minor version' do
      expect(migration.should_apply_to? '1.3.1').to be_false
    end

    it 'is false for a newer major version' do
      expect(migration.should_apply_to? '3.0.0').to be_false
    end

    it 'is true for an older bugfix version' do
      expect(migration.should_apply_to? '1.2.2').to be_true
    end

    it 'is true for an older minor version' do
      expect(migration.should_apply_to? '1.0.0').to be_true
    end

    it 'is true for an older major version' do
      expect(migration.should_apply_to? '0.5.15').to be_true
    end
  end

  describe '#apply' do
    it 'raises NotImplementedError' do
      expect { migration.apply(:working_dir, :object_store) }.to raise_error NotImplementedError
    end
  end

  describe '#revert' do
    it 'raises NotImplementedError' do
      expect { migration.revert(:working_dir, :object_store) }.to raise_error NotImplementedError
    end
  end
end