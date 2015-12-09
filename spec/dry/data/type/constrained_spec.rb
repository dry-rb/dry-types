RSpec.describe Dry::Data::Type::Constrained do
  describe '#[]' do
    it 'raises when a given constraint is violated' do
      string = Dry::Data['strict.string'].constrained(size: 3..12)

      expect(string['hello']).to eql('hello')

      expect { string['he'] }.to raise_error(Dry::Data::ConstraintError, /he/)
    end
  end
end
