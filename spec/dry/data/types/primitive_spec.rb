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

  context 'with "class"' do
    let(:type) { Dry::Data['class'] }

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end
  end

  context 'with "strict.class"' do
    let(:type) { Dry::Data['strict.class'] }

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end

    it 'raises when input is not a class' do
      expect { type['String'] }.to raise_error(TypeError, /String/)
    end
  end
end
