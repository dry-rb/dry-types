RSpec.describe Dry::Data::SumType do
  describe '#[]' do
    it 'works with two pass-through types' do
      type = Dry::Data['int'] | Dry::Data['string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')
    end

    it 'works with two strict types' do
      type = Dry::Data['strict.int'] | Dry::Data['strict.string']

      expect(type[312]).to be(312)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end

    it 'works with nil and strict types' do
      type = Dry::Data['nil'] | Dry::Data['strict.string']

      expect(type[nil]).to be(nil)
      expect(type['312']).to eql('312')

      expect { type[{}] }.to raise_error(TypeError)
    end
  end
end
