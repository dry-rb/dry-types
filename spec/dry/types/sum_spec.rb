RSpec.describe Dry::Types::Sum do
  describe '#[]' do
    it 'works with two pass-through types' do
      type = Dry::Types['int'] | Dry::Types['string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')
    end

    it 'works with two strict types' do
      type = Dry::Types['strict.int'] | Dry::Types['strict.string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end

    it 'works with nil and strict types' do
      type = Dry::Types['nil'] | Dry::Types['strict.string']

      expect(type[nil]).to be(nil)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end

    it 'is aliased as #call' do
      type = Dry::Types['int'] | Dry::Types['string']
      expect(type.call(312)).to be(312)
      expect(type.call('312')).to eql('312')
    end
  end

  describe '#default' do
    it 'returns a default value sum type' do
      type = (Dry::Types['nil'] | Dry::Types['string']).default('foo')

      expect(type[nil]).to eql('foo')
    end

    it 'supports a sum type which includes a constructor type' do
      type = (Dry::Types['form.nil'] | Dry::Types['form.int']).default(3)

      expect(type['']).to be(3)
    end

    it 'supports a sum type which includes a constrained constructor type' do
      type = (Dry::Types['strict.nil'] | Dry::Types['coercible.int']).default(3)

      expect(type[nil]).to be(3)
      expect(type['3']).to be(3)
      expect(type['7']).to be(7)
    end
  end
end
