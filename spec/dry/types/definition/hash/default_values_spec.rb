RSpec.describe Dry::Types::Definition::Hash, 'with default values' do
  subject(:hash) do
    Dry::Types['hash'].schema(name: 'string', password: password)
  end

  let(:password) { Dry::Types['strict.string'].default('changeme') }

  describe '#[]' do
    it 'fills in default values' do
      expect(hash[name: 'Jane']).to eql(
        name: 'Jane', password: 'changeme'
      )
    end
  end
end
