RSpec.describe Dry::Types::Hash, :maybe do
  let(:email) { Dry::Types['maybe.strict.string'] }

  context 'Symbolized constructor' do
    subject(:hash) do
      Dry::Types['hash'].symbolized(
        name: 'string',
        email: email
      )
    end

    describe '#[]' do
      it 'sets None as a default value for maybe' do
        result = hash['name' => 'Jane']

        expect(result[:email]).to be_none
      end
    end
  end

  context 'Schema constructor' do
    subject(:hash) do
      Dry::Types['hash'].schema(
        name: 'string',
        email: email
      )
    end

    describe '#[]' do
      it 'sets None as a default value for maybe types' do
        result = hash[name: 'Jane']

        expect(result[:email]).to be_none
      end
    end
  end

  context 'Strict with defaults' do
    subject(:hash) do
      Dry::Types['hash'].strict_with_defaults(
        name: 'string',
        email: email
      )
    end

    describe '#[]' do
      it 'sets None as a default value for maybe types' do
        result = hash[name: 'Jane']

        expect(result[:email]).to be_none
      end
    end
  end
end
