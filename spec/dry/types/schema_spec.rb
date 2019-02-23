RSpec.describe Dry::Types::Hash::Schema do
  subject(:schema) do
    Dry::Types['strict.hash'].schema(
      name: "coercible.string",
      age: "strict.integer",
      active: "params.bool"
    )
  end

  describe '#each' do
    it 'iterates over keys' do
      expect(schema.each.to_a).to eql(schema.name_key_map.values_at(*%i(name age active)))
    end

    it 'makes schema act as Enumerable' do
      expect(schema.map(&:name)).to eql(%i(name age active))
    end

    it 'returns enumerator' do
      enumerator = schema.each

      expect(enumerator.next).to be(schema.name_key_map[:name])
    end
  end

  describe '#key?' do
    it 'checks key presence' do
      expect(schema.key?(:name)).to be true
      expect(schema.key?(:missing)).to be false
    end
  end

  describe '#key' do
    it 'fetches a key type' do
      expect(schema.key(:name)).to be(schema.name_key_map[:name])
    end

    it 'raises a key error if key is unknown' do
      expect { schema.key(:missing) }.to raise_error(KeyError, "key not found: :missing")
    end

    it 'accepts a fallback' do
      expect(schema.key(:missing, :fallback)).to eql(:fallback)
    end

    it 'accepts a fallback block' do
      expect(schema.key(:missing) { :fallback }).to eql(:fallback)
    end
  end
end
