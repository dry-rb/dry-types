RSpec.describe Dry::Data::Type::Array do
  describe '#member' do
    it 'returns array with member type' do
      array = Dry::Data['coercible.array<coercible.string>']

      input = Set[1, 2, 3]

      expect(array[input]).to eql(%w(1 2 3))
    end
  end
end
