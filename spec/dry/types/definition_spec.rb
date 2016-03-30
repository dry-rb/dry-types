RSpec.describe Dry::Types::Definition do
  subject(:type) { Dry::Types::Definition.new(String) }

  it_behaves_like 'Dry::Types::Definition#meta'

  it 'is frozen' do
    expect(type).to be_frozen
  end

  describe '#constructor' do
    it 'returns a constructor' do
      coercible_string = type.constructor(&:to_s)

      expect(coercible_string[{}]).to eql({}.to_s)
    end
  end
end
