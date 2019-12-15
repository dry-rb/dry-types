# frozen_string_literal: true

RSpec.describe Dry::Types::Nominal, '#maybe', :maybe do
  context 'with a nominal' do
    subject(:type) { Dry::Types['nominal.string'].maybe }

    it_behaves_like 'Dry::Types::Nominal without primitive'

    it 'returns None when value is nil' do
      expect(type[nil]).to be_none
    end

    it 'returns Some when value exists' do
      expect(type['hello'].value!).to eql('hello')
    end

    it 'returns original if input is already a maybe' do
      expect(type[Dry::Monads::Maybe::Some.new('hello')].value!).to eql('hello')
    end

    it 'aliases #[] as #call' do
      expect(type.call('hello').value!).to eql('hello')
    end

    it 'does not have primitive' do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context 'with a strict type' do
    subject(:type) { Dry::Types['strict.integer'].maybe }

    it_behaves_like 'Dry::Types::Nominal without primitive'

    it 'returns None when value is nil' do
      expect(type[nil]).to be_none
    end

    it 'returns Some when value exists' do
      expect(type[231].value!).to be(231)
    end

    it 'returns original if input is already a maybe' do
      expect(type[Dry::Monads::Maybe.lift(231)].value!).to be(231)
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['nominal.bool'].maybe }

    it_behaves_like 'Dry::Types::Nominal without primitive'

    it 'returns None when value is nil' do
      expect(type[nil]).to be_none
    end

    it 'returns Some when value exists' do
      expect(type[true].value!).to be(true)
      expect(type[false].value!).to be(false)
    end

    it 'does not have primitive' do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context 'with keys' do
    subject(:type) do
      Dry::Types['hash'].schema(foo: Dry::Types['integer']).key(:foo)
    end

    it 'gets wrapped by key type' do
      expect(type.maybe).to be_a(Dry::Types::Schema::Key)
      expect(type.maybe[nil]).to be_none
      expect(type.maybe[1]).to be_some
    end
  end

  describe '#try' do
    before do
      require 'dry/monads'
      extend Dry::Monads[:maybe]
    end

    subject(:type) { Dry::Types['coercible.integer'].optional.maybe }

    it 'maps successful result' do
      expect(type.try('1')).to eql(Dry::Types::Result::Success.new(Some(1)))
      expect(type.try(nil)).to eql(Dry::Types::Result::Success.new(None()))
      expect(type.try('a')).to be_a(Dry::Types::Result::Failure)
    end
  end
end
