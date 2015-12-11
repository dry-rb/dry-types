RSpec.describe Dry::Data::Type::Constrained do
  describe '#[]' do
    subject(:type) do
      Dry::Data['strict.string'].constrained(size: 3..12)
    end

    it 'passes when constraints are not violated' do
      expect(type['hello']).to eql('hello')
    end

    it 'raises when a given constraint is violated' do
      expect { type['he'] }.to raise_error(Dry::Data::ConstraintError, /he/)
    end
  end

  context 'with a sum type' do
    subject(:type) do
      Dry::Data['string'].constrained(size: 4).optional
    end

    it 'passes when constraints are not violated' do
      expect(type[nil].value).to be(nil)
      expect(type['hell'].value).to eql('hell')
    end

    it 'raises when a given constraint is violated' do
      expect { type['hel'] }.to raise_error(Dry::Data::ConstraintError, /hel/)
    end
  end
end
