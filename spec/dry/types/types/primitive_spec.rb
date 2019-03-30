RSpec.describe Dry::Types, '.[]' do
  context 'with "symbol"' do
    let(:type) { Dry::Types['symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end
  end

  context 'with "strict.symbol"' do
    let(:type) { Dry::Types['strict.symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end

    it 'raises a coercion error when it is not a symbol' do
      expect { type[Object.new] }.to raise_error(Dry::Types::CoercionError)
    end
  end

  context 'with "class"' do
    let(:type) { Dry::Types['nominal.class'] }

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end
  end

  context 'with "strict.class"' do
    let(:type) { Dry::Types['strict.class'] }

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end

    it 'raises when input is not a class' do
      expect { type['String'] }.to raise_error(Dry::Types::CoercionError, /String/)
    end
  end
end
