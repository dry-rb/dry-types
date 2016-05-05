RSpec.describe Dry::Types::Hash, ':symbolized constructor' do
  subject(:hash) do
    Dry::Types['hash'].symbolized(
      name: 'string',
      middle_name: 'maybe.strict.string',
      age: 'int',
      password: password
    )
  end

  let(:password) { Dry::Types['strict.string'].default('changeme') }

  describe '#[]' do
    it 'changes string keys to symbols' do
      expect(hash['name' => 'Jane', 'age' => 1]).to include(
        name: 'Jane', age: 1, password: 'changeme'
      )
    end

    it 'sets default when value is nil' do
      expect(hash['name' => 'Jane', 'age' => 1, 'password' => nil]).to include(
        name: 'Jane', age: 1, password: 'changeme'
      )
    end

    it 'sets None as a default value for optional' do
      result = hash['name' => 'Jane', 'age' => 1]

      expect(result[:middle_name]).to be_instance_of(Dry::Monads::Maybe::None)
    end

    it 'passes through already symbolized hash' do
      result = hash[name: 'Jane', age: 1, middle_name: 'Alice']

      expect(result).to include(name: 'Jane', age: 1, password: 'changeme')
      expect(result[:middle_name].value).to eql('Alice')
    end
  end
end
