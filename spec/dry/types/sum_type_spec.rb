RSpec.describe Dry::Types::SumType do
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
end
