RSpec.describe Dry::Types::Hash, 'with default values' do
  subject(:hash) do
    Dry::Types['hash'].schema(
      name: 'string',
      middle_name: 'maybe.strict.string',
      password: password,
      created_at: created_at
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

    it 'sets None as a default value for optional types' do
      result = hash[name: 'Jane']

      expect(result[:middle_name]).to be_instance_of(Kleisli::Maybe::None)
    end
  end
end
