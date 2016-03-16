RSpec.describe Dry::Types::Definition::Hash, 'with default values' do
  subject(:hash) do
    Dry::Types['hash'].schema(
      name: 'string', password: password, created_at: created_at
    )
  end

  let(:password) { Dry::Types['strict.string'].default('changeme') }
  let(:created_at) { Dry::Types['strict.time'].default { Time.now } }

  describe '#[]' do
    it 'fills in default values' do
      result = hash[name: 'Jane']

      expect(result).to include(
        name: 'Jane', password: 'changeme'
      )

      expect(result[:created_at]).to be_instance_of(Time)
    end
  end
end
