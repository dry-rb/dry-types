RSpec.describe Dry::Types::Definition, '#maybe' do
  before(:all) do
    Dry::Types.load_extensions(:maybe)
  end

  context 'with a definition' do
    subject(:type) { Dry::Types['string'].maybe }

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'returns None when value is nil' do
      expect(type[nil].value).to be(nil)
    end

    it 'returns Some when value exists' do
      expect(type['hello'].value).to eql('hello')
    end

    it 'returns original if input is already a maybe' do
      expect(type[Dry::Monads::Maybe::Some.new('hello')].value).to eql('hello')
    end

    it 'aliases #[] as #call' do
      expect(type.call('hello').value).to eql('hello')
    end

    it 'does not have primitive' do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context 'with a strict type' do
    subject(:type) { Dry::Types['strict.int'].maybe }

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'returns None when value is nil' do
      expect(type[nil].value).to be(nil)
    end

    it 'returns Some when value exists' do
      expect(type[231].value).to be(231)
    end

    it 'returns original if input is already a maybe' do
      expect(type[Dry::Monads::Maybe.lift(231)].value).to be(231)
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['bool'].maybe }

    it_behaves_like 'Dry::Types::Definition without primitive'

    it 'returns None when value is nil' do
      expect(type[nil].value).to be(nil)
    end

    it 'returns Some when value exists' do
      expect(type[true].value).to be(true)
      expect(type[false].value).to be(false)
    end

    it 'does not have primitive' do
      expect(type).to_not respond_to(:primitive)
    end
  end
end
