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

    it 'raises when input is not a symbol' do
      expect { type['hello'] }.to raise_error(TypeError, /hello/)
    end
  end

  context 'with "coercible.symbol"' do
    let(:type) { Dry::Types['coercible.symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end

    it 'coerces a string' do
      expect(type['hello']).to be(:hello)
    end
  end

  context 'with "class"' do
    let(:type) { Dry::Types['class'] }

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
      expect { type['String'] }.to raise_error(TypeError, /String/)
    end
  end
end
