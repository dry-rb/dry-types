RSpec.describe Dry::Types::Hash, ':symbolized constructor' do
  subject(:hash) do
    Dry::Types['hash'].symbolized(
      name: 'strict.string',
      middle_name: 'maybe.strict.string',
      age: Dry::Types['strict.int'].optional,
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

    it 'sets None as a default value for maybe' do
      result = hash['name' => 'Jane', 'age' => 1]

      expect(result[:middle_name]).to be_instance_of(Dry::Monads::Maybe::None)
    end

    it 'passes through already symbolized hash' do
      result = hash[name: 'Jane', age: 1, middle_name: 'Alice']

      expect(result).to include(name: 'Jane', age: 1, password: 'changeme')
      expect(result[:middle_name].value).to eql('Alice')
    end

    it 'raises an error on attempt to omit key associated with a strict type' do
      expect { hash[middle_name: 'Alice'] }.to raise_error(
        Dry::Types::ConstraintError,
        'nil violates constraints (type?(String) failed)'
      )
    end

    it 'sets nil as a default value for optional' do
      result = hash['name' => 'Jane']

      expect(result[:age]).to be_nil
    end
  end
end
