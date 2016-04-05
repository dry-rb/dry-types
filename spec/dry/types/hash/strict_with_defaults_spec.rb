RSpec.describe Dry::Types::Hash, '#strict_with_defaults' do
  subject(:hash) do
    Dry::Types['hash'].strict_with_defaults(
      age: 'strict.int',
      name: name
    )
  end

  let(:name) { Dry::Types['strict.string'].default('New User') }

  describe '#[]' do
    it 'sets default values' do
      result = hash[age: 18]

      expect(result).to include(
        name: 'New User', age: 18
      )
    end

    it 'raises an error for attributes without default values' do
      expect { hash[name: 'Jane'] }.to raise_error(Dry::Types::SchemaKeyError)
    end
  end
end
