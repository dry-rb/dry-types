RSpec.describe Dry::Types::Definition::Hash, ':symbolized constructor' do
  subject(:hash) do
    Dry::Types['hash'].symbolized(name: 'string', age: 'int', password: password)
  end

  let(:password) { Dry::Types['strict.string'].default('changeme') }

  describe '#[]' do
    it 'changes string keys to symbols' do
      expect(hash['name' => 'Jane', 'age' => 1]).to eql(
        name: 'Jane', age: 1, password: 'changeme'
      )
    end

    it 'sets default when value is nil' do
      expect(hash['name' => 'Jane', 'age' => 1, 'password' => nil]).to eql(
        name: 'Jane', age: 1, password: 'changeme'
      )
    end

    it 'passes through already symbolized hash' do
      expect(hash[name: 'Jane', age: 1]).to eql(
        name: 'Jane', age: 1, password: 'changeme'
      )
    end
  end
end
