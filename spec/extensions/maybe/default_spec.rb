RSpec.describe Dry::Types::Definition, '#default' do
  context 'with a maybe' do
    subject(:type) { Dry::Types['strict.int'].maybe }

    it_behaves_like 'Dry::Types::Definition without primitive' do
      let(:type) { Dry::Types['strict.int'].maybe.default(0) }
    end

    it 'does not allow nil' do
      expect { type.default(nil) }.to raise_error(ArgumentError, /nil/)
    end

    it 'accepts a non-nil value' do
      expect(type.default(0)[0].value).to be(0)
    end
  end
end
