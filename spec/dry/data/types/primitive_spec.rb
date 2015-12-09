RSpec.describe Dry::Data, '.[]' do
  context 'with "symbol"' do
    let(:type) { Dry::Data['symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end
  end

  context 'with "strict.symbol"' do
    let(:type) { Dry::Data['strict.symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end

    it 'raises when input is not a symbol' do
      expect { type['hello'] }.to raise_error(TypeError, /hello/)
    end
  end
end
