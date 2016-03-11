RSpec.describe Dry::Types::Definition, '#optional' do
  context 'with a definition' do
    subject(:type) { Dry::Types['string'].optional }

    it 'returns None when value is nil' do
      expect(type[nil].value).to be(nil)
    end

    it 'returns Some when value exists' do
      expect(type['hello'].value).to eql('hello')
    end

    it 'aliases #[] as #call' do
      expect(type.call('hello').value).to eql('hello')
    end

    it 'does not have primitive' do
      expect(type).to_not respond_to(:primitive)
    end
  end

  context 'with a sum' do
    subject(:type) { Dry::Types['bool'].optional }

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
