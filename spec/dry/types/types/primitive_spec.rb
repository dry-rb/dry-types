# frozen_string_literal: true

RSpec.describe Dry::Types, '.[]' do
  context 'with "symbol"' do
    let(:type) { Dry::Types['symbol'] }

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end
  end

  context 'with "strict.symbol"' do
    let(:type) { Dry::Types['strict.symbol'] }

    it_behaves_like 'a constrained type'

    it 'passes through a symbol' do
      expect(type[:hello]).to be(:hello)
    end
  end

  context 'with "nominalclass"' do
    let(:type) { Dry::Types['nominal.class'] }

    it_behaves_like 'a nominal type'

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end
  end

  context 'with "strict.class"' do
    let(:type) { Dry::Types['strict.class'] }

    it_behaves_like 'a constrained type', inputs: [
      Object.new, 'String'
    ]

    it 'passes through a class' do
      expect(type[String]).to be(String)
    end
  end
end
